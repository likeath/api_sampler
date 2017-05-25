# frozen_string_literal: true
module ApiSampler
  class Sample
    FIELDS = %i(
      time
      request_method
      request_path
      request_query_string
      request_body
      response_code
      response_body
      tag_names
      duration
    ).freeze

    private

    attr_accessor :start_at, :end_at, :tags,
                  :request_path, :request_body,
                  :request_method, :request_query_string,
                  :response_code, :response_body

    public

    attr_reader :request_path, :request_method,
                :request_query_string, :request_body,
                :response_body, :response_code,
                :tags

    def initialize
      self.tags = []
    end

    def start(env)
      self.request_path = env.fetch('PATH_INFO')
      self.request_method = env.fetch('REQUEST_METHOD')
      self.request_query_string = env.fetch('QUERY_STRING')
      self.request_body = env.fetch('rack.input').read

      self.start_at = Utils.current_time_in_milliseconds

      self
    end

    def finish(code, response)
      self.response_code = code.to_i
      self.response_body = if response.respond_to?(:body)
                             response.body
                           else
                             response.to_s
                           end
      self.end_at = Utils.current_time_in_milliseconds

      self
    end

    def add_tags(taggers)
      tags.push(
        *taggers.select { |tagger| tagger.match?(self) }.map(&:tag)
      )
    end

    def duration
      end_at - start_at
    end

    def time
      Utils.timestamp_from_milliseconds(start_at)
    end

    def active?
      !start_at.nil? && end_at.nil?
    end

    def tag_names
      tags.join(', ')
    end

    def to_hash
      FIELDS.map do |field|
        [field, public_send(field)]
      end.to_h
    end
  end
end
