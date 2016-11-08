# frozen_string_literal: true
require 'rack'
require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'api_sampler'

RSpec.configure do |config|
  config.raise_errors_for_deprecations!

  config.mock_with :rspec do |mocks|
   mocks.allow_message_expectations_on_nil = false
  end
end
