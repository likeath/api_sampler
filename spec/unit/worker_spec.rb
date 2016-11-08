# frozen_string_literal: true
require 'spec_helper'

describe ApiSampler::Worker do
  let(:store) { ->(_) { :ok } }
  let(:request_env) do
    Rack::MockRequest.env_for('/api/endpoint?a=1&b=2')
  end
  let(:response) do
    [
      '200',
      { 'Content-Type' => 'application/json' },
      '{"ping":"pong"}'
    ]
  end

  describe '.current' do
    it 'returns same worker' do
      current_worker = ApiSampler::Worker.current
      expect(ApiSampler::Worker.current).to eq(current_worker)
    end
  end

  context 'when sampling is active' do
    let(:worker) do
      checker = Struct.new(:_) do
        def sampling_active?(_)
          true
        end
      end.new
      configuration = Struct.new(:store_instance, :checker, :taggers)
        .new(store, checker, [])

      ApiSampler::Worker.new(configuration: configuration)
    end

    describe '#handle_request' do
      it 'call Sample#start' do
        expect_any_instance_of(ApiSampler::Sample).to receive(:start).once.with(request_env)
        worker.handle_request(request_env)
      end
    end

    describe '#started?' do
      it 'returns true' do
        worker.handle_request(request_env)
        expect(worker.active?).to eq(true)
      end
    end

    describe '#handle_response' do
      before do
        worker.handle_request(request_env)
      end
      it 'send `finish` and `add_tags` to sample' do
        expect(worker.sample).to(
          receive(:finish)
            .once
            .with(response.first, response.last)
            .and_return(worker.sample)
        )

        worker.handle_response(*response)
      end
      it 'send `add_tags` to sample' do
        expect(worker.sample).to receive(:add_tags).once.with(worker.taggers)
        worker.handle_response(*response)
      end
      it 'send `call` to store' do
        worker.handle_request(request_env)

        expect(store).to receive(:call).once.with(worker.sample)
        worker.handle_response(*response)
      end
    end
  end

  context 'when sampling is not active' do
    let(:worker) do
      checker = Struct.new(:_) do
        def sampling_active?(_)
          false
        end
      end.new
      configuration = Struct.new(:store_instance, :checker, :taggers)
        .new(store, checker, [])

      ApiSampler::Worker.new(configuration: configuration)
    end

    describe '#handle_request' do
      it 'not call Sample#start' do
        expect_any_instance_of(ApiSampler::Sample).to_not receive(:start)
        worker.handle_request(request_env)
      end
    end

    describe '#started?' do
      it 'returns false' do
        worker.handle_request(request_env)
        expect(worker.active?).to eq(false)
      end
    end

    describe '#handle_response' do
      it 'not send `finish` to sample' do
        expect_any_instance_of(ApiSampler::Sample).to_not receive(:finish)
        worker.handle_request(request_env)
      end
    end
  end
end
