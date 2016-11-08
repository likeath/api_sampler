# frozen_string_literal: true
require 'spec_helper'

describe ApiSampler::Sample do
  let(:env) { Rack::MockRequest.env_for('/api/endpoint?a=1&b=2') }
  let(:started_sample) { ApiSampler::Sample.new.start(env) }
  let(:response_code_and_body) { [200, '{"ping":"pong"}'] }

  describe '.new' do
    it 'not active' do
      expect(ApiSampler::Sample.new.active?).to eq(false)
    end
  end

  describe '#start' do
    let(:sample) { started_sample }
    it 'set request options' do
      expect(sample.request_path).to eq('/api/endpoint')
      expect(sample.request_method).to eq('GET')
      expect(sample.request_query_string).to eq('a=1&b=2')
      expect(sample.request_body).to eq('')
    end
    it 'start sampling' do
      expect(sample.active?).to eq(true)
      expect(sample.time).to_not eq(nil)
    end
  end

  describe '#finish' do
    let(:sample) { started_sample.finish(*response_code_and_body) }
    it 'stop sampling' do
      expect(sample.active?).to eq(false)
      expect(sample.duration).to_not eq(nil)
    end
    it 'set response options' do
      expect(sample.response_code).to eq(200)
      expect(sample.response_body).to eq('{"ping":"pong"}')
    end
  end

  describe '#to_hash' do
    let(:sample) do
      started_sample.finish(*response_code_and_body)
    end
    it 'return all keys' do
      result = sample.to_hash

      %i(time request_method request_path request_query_string request_body response_body tag_names).each do |field|
        expect(result).to have_key(field)
      end
    end
  end

  describe '#add_tags' do
    let(:taggers) do
      [
        ApiSampler::Tagger.new('error', ->(sample) { sample.response_code == 500 }),
        ApiSampler::Tagger.new('success', ->(sample) { sample.response_code == 200 }),
        ApiSampler::Tagger.new('pong', ->(sample) { sample.response_body =~ /pong/ })
      ]
    end
    context 'for successful sample' do
      it 'sets success and pong tags' do
        sample = started_sample.finish(*response_code_and_body)
        sample.add_tags(taggers)

        expect(sample.tags).to eq(%w(success pong))
        expect(sample.tag_names).to eq('success, pong')
      end
    end

    context 'for error sample' do
      it 'sets error tag' do
        sample = started_sample.finish(500, '{"error":"server error"}')
        sample.add_tags(taggers)

        expect(sample.tags).to eq(['error'])
        expect(sample.tag_names).to eq('error')
      end
    end
  end
end
