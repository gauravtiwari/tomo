concurrent_ver = "~> 1.1"

begin
  gem "concurrent-ruby", concurrent_ver
  require "concurrent"
rescue LoadError => error
  Jam::Framework::ConcurrentRubyLoadError.raise_with(
    error.message,
    version: concurrent_ver
  )
end

module Jam
  class Framework
    class ConcurrentRubyThreadPool
      include ::Concurrent::Promises::FactoryMethods

      attr_writer :failure

      def initialize(size)
        @executor = ::Concurrent::FixedThreadPool.new(size)
        @promises = []
      end

      def post(*args, &block)
        return if failure?

        promises << future_on(executor, *args, &block)
        nil
      end

      def run_to_completion
        promises_to_wait = promises.dup
        promises.clear
        zip_futures_on(executor, *promises_to_wait).value
        raise @failure if failure?
      end

      def failure?
        !!@failure
      end

      private

      attr_reader :executor, :promises
    end
  end
end
