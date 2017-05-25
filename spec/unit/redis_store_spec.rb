# frozen_string_literal: true
require 'spec_helper'

describe ApiSampler::Store::Redis do
  FakeSample = Struct.new(:time, :request_path) do
    def to_hash
      {
        time: time,
        request_path: request_path,
        ping: 'pong'
      }
    end
  end

  let(:store) do
    ApiSampler::Store::Redis.new(url: ENV.fetch('REDIS_URL'))
  end

  context 'general interaction' do
    let(:sample_users) do
      FakeSample.new(1_478_606_774_893, '/api/users.json')
    end
    let(:sample_users_2) do
      FakeSample.new(1_478_806_774_893, '/api/users.json')
    end
    let(:sample_logs) do
      FakeSample.new(1_478_596_774_893, '/api/logs.json')
    end
    let(:sample_logs_2) do
      FakeSample.new(1_478_400_774_893, '/api/logs.json')
    end
    before do
      store.clear

      store.call(sample_users)
      store.call(sample_users_2)
      store.call(sample_logs)
      store.call(sample_logs_2)
    end
    describe '#endpoints' do
      it 'returns uniq endpoints' do
        expect(store.endpoints.sort).to eq(
          ['/api/users.json', '/api/logs.json'].sort
        )
      end
    end
    describe '#fetch_samples' do
      it 'returns all samples in correct order – from newest to older' do
        expect(store.fetch_samples).to eq(
          [sample_users_2, sample_users, sample_logs, sample_logs_2]
            .map { |sample| ApiSampler::Utils.to_json(sample.to_hash) }
        )
      end
    end
    describe '#remove_samples' do
      it 'removes only needed samples' do
        store.remove_samples(
          '/api/users.json',
          1_478_606_774_893,
          1_478_806_774_893
        )

        expect(store.fetch_samples).to eq(
          [sample_logs, sample_logs_2]
            .map { |sample| ApiSampler::Utils.to_json(sample.to_hash) }
        )
      end
    end
    describe '#clear' do
      it 'remove all endpoints & samples' do
        store.clear

        expect(store.endpoints).to eq([])
        expect(store.fetch_samples).to eq([])
      end
    end
  end
end
