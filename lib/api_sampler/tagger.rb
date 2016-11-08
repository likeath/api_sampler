# frozen_string_literal: true
module ApiSampler
  class Tagger
    private

    attr_accessor :matcher
    attr_writer :tag

    public

    attr_reader :tag

    def initialize(tag, matcher)
      self.tag = tag
      self.matcher = matcher
    end

    def match?(worker)
      matcher.call(worker)
    end
  end
end
