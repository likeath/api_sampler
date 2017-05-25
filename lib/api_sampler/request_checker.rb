# frozen_string_literal: true
module ApiSampler
  # TODO: better name
  #  That class` responsibility is checking if sample need to be made
  class RequestChecker
    private

    attr_accessor :configuration, :random_generator, :request_path

    public

    def initialize(configuration: ApiSampler.configuration,
                   random_generator: Random)
      self.configuration = configuration
      self.random_generator = random_generator
    end

    def sampling_active?(request_path)
      self.request_path = request_path

      request_matches? &&
        not_in_blacklist? &&
        fall_in_samplerate? &&
        in_frequency?
    end

    private

    def request_matches?
      !(request_path =~ configuration.path_matcher).nil?
    end

    def not_in_blacklist?
      configuration.blacklist.none? do |blacklist_entry|
        blacklist_entry == request_path
      end
    end

    def fall_in_samplerate?
      random_generator.rand(100) <= configuration.sample_rate_percent
    end

    # TODO: actual check frequency
    def in_frequency?
      true
    end
  end
end
