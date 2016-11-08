# frozen_string_literal: true
require 'spec_helper'

describe ApiSampler::RequestChecker do
  describe '#sampling_active?' do
    let(:configuration) do
      Struct
        .new(:path_matcher, :blacklist, :sample_rate_percent)
        .new(%r{\A/api/}, [], 65)
    end
    let(:successful_rand) do
      Struct.new(:_) do
        def rand(*)
          30
        end
      end.new
    end
    let(:request_path) { '/api/endpoint' }

    context 'for path_matcher' do
      context 'when request not matches' do
        it 'returns false' do
          checker = ApiSampler::RequestChecker.new(
            configuration: configuration,
            random_generator: successful_rand
          )

          expect(checker.sampling_active?('/web/api/endpoint')).to eq(false)
        end
      end
      context 'when request matches' do
        it 'returns true' do
          checker = ApiSampler::RequestChecker.new(
            configuration: configuration,
            random_generator: successful_rand
          )

          expect(checker.sampling_active?(request_path)).to eq(true)
        end
      end
    end

    context 'for blacklist' do
      context 'when request in blacklist' do
        it 'returns false' do
          checker = ApiSampler::RequestChecker.new(
            configuration: configuration.tap { |c| c.blacklist = ['/api/endpoint'] },
            random_generator: successful_rand
          )

          expect(checker.sampling_active?(request_path)).to eq(false)
        end
      end
      context 'when request not in blacklist' do
        it 'returns true' do
          checker = ApiSampler::RequestChecker.new(
            configuration: configuration.tap { |c| c.blacklist = ['/api/users'] },
            random_generator: successful_rand
          )

          expect(checker.sampling_active?(request_path)).to eq(true)
        end
      end
    end

    context 'for sample_rate_percent' do
      context 'when request in sample rate' do
        it 'returns true' do
          checker = ApiSampler::RequestChecker.new(
            configuration: configuration,
            random_generator: successful_rand
          )

          expect(checker.sampling_active?(request_path)).to eq(true)
        end
      end
      context 'when request not in sample rate' do
        it 'returns false' do
          generator = Struct.new(:_) do
            def rand(*)
              88
            end
          end.new

          checker = ApiSampler::RequestChecker.new(
            configuration: configuration,
            random_generator: generator
          )

          expect(checker.sampling_active?(request_path)).to eq(false)
        end
      end
    end
  end
end
