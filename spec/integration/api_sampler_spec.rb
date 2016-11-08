# frozen_string_literal: true
require 'spec_helper'

describe ApiSampler do
  FakeResponse = Struct.new(:body, :code)
  FakeRackApp = Struct.new(:app) do
    def call(env)
      response_body = ApiSampler::Utils.to_json(hello: env.fetch('PATH_INFO'))
      [200, {}, FakeResponse.new(response_body, 200)]
    end
  end
  let(:fake_app) { FakeRackApp.new }
  let(:users_request) { Rack::MockRequest.env_for('/api/users') }
  let(:logs_request) { Rack::MockRequest.env_for('/api/logs') }

  context 'with sample rate = 100' do
    before do
      ApiSampler.configure do |config|
        config.store = :redis
        config.redis_config = { url: ENV.fetch('REDIS_URL') }
        config.sample_rate_percent = 100
      end
      ApiSampler.store.clear

      @middleware = ApiSampler::Middleware.new(fake_app)
    end

    it 'returns app response' do
      result_users = @middleware.call(users_request)
      result_logs = @middleware.call(logs_request)
      other_result_users = @middleware.call(users_request)

      expect(result_users).to eq(fake_app.call(users_request))
      expect(result_logs).to eq(fake_app.call(logs_request))
      expect(other_result_users).to eq(fake_app.call(users_request))
    end

    it 'sets correct data in redis' do
      @middleware.call(users_request)
      sleep(0.5)
      @middleware.call(logs_request)
      sleep(0.5)
      @middleware.call(users_request)

      store = ApiSampler.store

      expect(store.endpoints).to eq(
        ['/api/logs', '/api/users']
      )

      samples = store.fetch_samples.map do |sample|
        ApiSampler::Utils.from_json(sample)
      end

      expect(samples.size).to eq(3)
      expect(samples.map { |sample| sample[:request_path] }).to eq(
        ['/api/logs', '/api/users', '/api/users']
      )
    end
  end
end
