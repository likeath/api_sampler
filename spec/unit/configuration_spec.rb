# frozen_string_literal: true
require 'spec_helper'

describe ApiSampler::Configuration do
  describe '#assert_valid_configuration' do
    let(:error_class) { ApiSampler::Configuration::Error }

    context 'for new instance' do
      it 'valid' do
        expect { ApiSampler::Configuration.new }.to_not raise_error
      end
    end

    context 'for configured' do
      let(:config) { ApiSampler::Configuration.new }
      context 'with incorrect path_matcher' do
        it 'raise error' do
          config.path_matcher = 'api'
          expect { config.assert_valid_configuration }.to raise_error(error_class)
        end
      end
      context 'with incorrect sample_rate_percent' do
        context 'when sample_rate_percent is bigger' do
          it 'raise error' do
            config.sample_rate_percent = 150
            expect { config.assert_valid_configuration }.to raise_error(error_class)
          end
        end
        context 'when sample_rate_percent is smaller' do
          it 'raise error' do
            config.sample_rate_percent = 0
            expect { config.assert_valid_configuration }.to raise_error(error_class)
          end
        end
      end
      context 'for store' do
        context 'when store is not from available' do
          it 'raise error' do
            config.store = :database
            expect { config.assert_valid_configuration }.to raise_error(error_class)
          end
        end
        context 'for custom store' do
          context 'when custom_store don`t respond to call' do
            it 'raise error' do
              config.store = :custom
              config.custom_store = Struct.new(:name).new

              expect { config.assert_valid_configuration }.to raise_error(error_class)
            end
          end
          context 'when custom_store respond to call' do
            it 'ok' do
              config.store = :custom
              config.custom_store = ->(x) { puts x }

              expect { config.assert_valid_configuration }.to_not raise_error
            end
          end
        end
        context 'for log store' do
          context 'when logger is not set' do
            it 'raise error' do
              config.store = :log
              config.logger = nil

              expect { config.assert_valid_configuration }.to raise_error(error_class)
            end
          end
          context 'when logger is set' do
            it 'ok' do
              config.store = :log
              config.logger = Logger.new(STDOUT)

              expect { config.assert_valid_configuration }.to_not raise_error
            end
          end
        end
        context 'for redis store' do
          context 'when redis_config is not provided' do
            it 'raise error' do
              config.store = :redis

              expect { config.assert_valid_configuration }.to raise_error(error_class)
            end
          end
          context 'when redis_config is provided' do
            it 'ok' do
              config.store = :redis
              config.redis_config = { host: '', port: '' }

              expect { config.assert_valid_configuration }.to_not raise_error
            end
          end
        end
      end
    end
  end

  describe '#tag_with' do
    context 'with valid matcher' do
      it 'add to taggers' do
        config = ApiSampler::Configuration.new
        config.tag_with('tag1', -> {})
        config.tag_with('tag2', -> {})

        expect(config.taggers.size).to eq(2)
      end
    end
    context 'with invalid matcher' do
      it 'raise error' do
        config = ApiSampler::Configuration.new

        expect { config.tag_with('tag3', true) }.to raise_error(ApiSampler::Configuration::Error)
      end
    end
  end
end
