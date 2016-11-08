# frozen_string_literal: true
module ApiSampler
  module Store
    class Log
      private

      attr_accessor :logger

      public

      def initialize(logger)
        self.logger = logger
      end

      def call(worker)
        logger.info(
          worker.to_hash.values.join(' -- ')
        )
      end

      def clear
      end
    end
  end
end
