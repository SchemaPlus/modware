require 'its-it'
require 'key_struct'

module Modware
  class Stack
    def initialize(env:)
      @env_klass = case env
                   when Class then env
                   else KeyStruct[*env]
                   end
      @middlewares = []
    end

    def add(mod)
      middleware = Middleware.new(self, mod)
      @middlewares.last._next = middleware if @middlewares.any?
      @middlewares << middleware
    end

    def start(*args, &implementation)
      env = @env_klass.new(*args)
      @base_implementation = implementation
      execute_stack(env)
      env
    end

    private

    def execute_stack(env)
      return call_implementation(env) unless @middlewares.any?

      @middlewares.each do |middleware|
        middleware.before env if middleware.respond_to? :before
      end

      @middlewares.first._call(env)

      @middlewares.each do |middleware|
        middleware.after env if middleware.respond_to? :after
      end
    end

    def call_implementation(env)
      if middleware = @middlewares.select(&it.respond_to?(:implement)).last
        middleware.implement(env)
      elsif @base_implementation
        @base_implementation.call env
      else
        raise StackError, "No base implementation nor middleware implementation in stack"
      end
    end

    class Middleware
      attr_accessor :_next

      def initialize(stack, mod)
        @stack = stack
        singleton_class.send :include, mod
      end

      def _call(env)
        if respond_to? :around
          around(env) { |env|
            _continue env
          }
        else
          _continue env
        end
      end

      def _continue(env)
        if self._next
          self._next._call(env)
        else
          @stack.send :call_implementation, env
        end
      end
    end
  end
end
