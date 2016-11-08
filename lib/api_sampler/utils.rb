# frozen_string_literal: true
module ApiSampler
  module Utils
    module_function

    def current_time_in_milliseconds
      (Time.now.to_f * 1_000).round
    end

    def timestamp_from_milliseconds(time)
      return unless time
      time / 1_000
    end

    def to_json(data)
      Oj.dump(data, mode: :compat)
    end

    def from_json(json_data)
      Oj.load(json_data, symbol_keys: true)
    end
  end
end
