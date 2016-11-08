# frozen_string_literal: true
require 'api_sampler/configuration'
require 'api_sampler/middleware'
require 'api_sampler/request_checker'
require 'api_sampler/sample'
require 'api_sampler/store'
require 'api_sampler/tagger'
require 'api_sampler/utils'
require 'api_sampler/worker'
require 'api_sampler/version'

require 'logger'
require 'oj'
require 'redis'

module ApiSampler
  class << self
    attr_accessor :configuration
  end

  module_function

  def init
    self.configuration ||= Configuration.new
  end

  def configure
    yield(configuration)
    configuration.refresh
  end

  def store
    configuration.store_instance
  end
end

ApiSampler.init
