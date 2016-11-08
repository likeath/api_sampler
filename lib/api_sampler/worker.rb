# frozen_string_literal: true
module ApiSampler
  class Worker
    private

    attr_accessor :store, :checker, :sample, :taggers

    public

    attr_reader :sample, :taggers

    def self.current
      Thread.current[:api_sampler_worker] ||= new
    end

    def initialize(configuration: ApiSampler.configuration)
      self.store = configuration.store_instance
      self.checker = configuration.checker
      self.taggers = configuration.taggers
    end

    def handle_request(env)
      reset_sampling
      start_sampling(env)

      self
    end

    def handle_response(code, _headers, response)
      return self unless active?

      finish_sampling(code, response)
      save_sampling

      self
    end

    def active?
      sample.active?
    end

    private

    def sample_request?(env)
      request_path = env.fetch('PATH_INFO')
      checker.sampling_active?(request_path)
    end

    def reset_sampling
      self.sample = Sample.new
    end

    def start_sampling(env)
      sample_request?(env) && sample.start(env)
    end

    def finish_sampling(code, response)
      sample
        .finish(code, response)
        .add_tags(taggers)
    end

    def save_sampling
      store.call(sample)
    end
  end
end
