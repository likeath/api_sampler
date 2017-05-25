# frozen_string_literal: true
module ApiSampler
  module Store
    class Redis
      private

      attr_accessor :redis

      public

      NAMESPACE = 'api_sampler'

      def initialize(config)
        self.redis = ::Redis.new(config)
      end

      def call(sample)
        redis.pipelined do
          add_endpoint(sample.request_path)
          add_sample(sample)
        end
      end

      def endpoints
        redis.smembers(endpoints_storage)
      end

      def fetch_samples
        endpoints.sort.flat_map do |endpoint|
          redis.zrevrange(
            samples_storage(endpoint),
            0,
            -1
          )
        end
      end

      def remove_samples(endpoint, from, to)
        redis.zremrangebyscore(
          samples_storage(endpoint),
          from,
          to
        )
      end

      def clear
        endpoints.each do |endpoint|
          redis.del(samples_storage(endpoint))
        end
        redis.del(endpoints_storage)
      end

      private

      def add_endpoint(endpoint)
        redis.sadd(endpoints_storage, endpoint)
      end

      def add_sample(sample)
        redis.zadd(
          samples_storage(sample.request_path),
          sample.time,
          Utils.to_json(sample.to_hash)
        )
      end

      def endpoints_storage
        "#{NAMESPACE}/endpoints"
      end

      def samples_storage(endpoint)
        "#{NAMESPACE}/samples|#{endpoint}"
      end
    end
  end
end
