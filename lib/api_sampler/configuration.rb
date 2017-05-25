# frozen_string_literal: true
module ApiSampler
  # Configuration options
  class Configuration
    Error = Class.new(StandardError)

    DEFAULTS = {
      path_matcher: %r{\A/api/},
      sample_rate_percent: 50,
      sample_limit_frequency: 10,
      sample_limit_period: 60
    }.freeze

    private

    attr_accessor :taggers, :store_instance

    public

    attr_accessor :path_matcher, :blacklist, :logger, :verbose,
                  :store, :custom_store, :redis_config,
                  :sample_rate_percent, :sample_limit_frequency,
                  :sample_limit_period

    attr_reader :taggers, :store_instance

    def initialize
      self.taggers = []
      self.blacklist = []

      self.path_matcher = DEFAULTS.fetch(:path_matcher)
      self.sample_rate_percent = DEFAULTS.fetch(:sample_rate_percent)
      self.sample_limit_frequency = DEFAULTS.fetch(:sample_limit_frequency)
      self.sample_limit_period = DEFAULTS.fetch(:sample_limit_period)

      self.logger = Logger.new(STDOUT)
      self.verbose = false
      self.store = :log

      refresh
    end

    def refresh
      assert_valid_configuration
      set_store
    end

    def tag_with(tag, matcher)
      assert_valid_tag_matcher(matcher)
      taggers.push(Tagger.new(tag, matcher))
    end

    def assert_valid_configuration
      assert_valid_main_options
      assert_valid_store
    end

    def checker
      @checker ||= RequestChecker.new
    end

    private

    def set_store
      self.store_instance = case store
                            when :log
                              Store::Log.new(logger)
                            when :redis
                              Store::Redis.new(redis_config)
                            when :custom
                              custom_store
                            end
    end

    def assert_valid_main_options
      raise Error, 'provide `path_matcher` option as Regexp' unless path_matcher.is_a?(Regexp)
      raise Error, '`sample_rate_percent` should be in 1..100' unless (1..100).cover?(sample_rate_percent)
    end

    # NOTE: move to Store module?
    def assert_valid_store
      raise Error, "invalid store, available store are: #{Store::AVAILABLE_STORES.join(', ')}" unless Store::AVAILABLE_STORES.include?(store)
      raise Error, 'provide `custom_store` that respond to `call`' if store == :custom && !custom_store.respond_to?(:call)
      raise Error, 'provide `logger` option for log store' if store == :log && logger.nil?
      raise Error, 'provide `redis_config` for redis store' if store == :redis && (redis_config.nil? || redis_config.empty?)
    end

    # TODO: move to Tagger class?
    def assert_valid_tag_matcher(tag_matcher)
      raise Error, 'provide tag matcher that respond to call' unless tag_matcher.respond_to?(:call)
    end
  end
end
