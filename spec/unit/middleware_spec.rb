# frozen_string_literal: true
require 'spec_helper'

describe ApiSampler::Middleware do
  let(:env) do
    Rack::MockRequest.env_for('/api/endpoint')
  end
  let(:response) do
    [200, {}, '{"ping":"pong"}']
  end
  let(:app) do
    ->(_) { response }
  end

  it 'returns app result' do
    expect(
      ApiSampler::Middleware.new(app).call(env)
    ).to eq(
      response
    )
  end

  it 'call Worker#handle_request' do
    expect(ApiSampler::Worker.current).to receive(:handle_request).once.with(env)
    ApiSampler::Middleware.new(app).call(env)
  end

  it 'call Worker#handle_response' do
    expect(ApiSampler::Worker.current).to receive(:handle_response).once.with(*response)
    ApiSampler::Middleware.new(app).call(env)
  end
end
