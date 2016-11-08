# frozen_string_literal: true
require 'api_sampler/store/redis'
require 'api_sampler/store/log'

module ApiSampler
  module Store
    AVAILABLE_STORES = %i(log redis custom).freeze
  end
end
