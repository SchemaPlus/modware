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
      execute_stack(env, implementation)
      env
    end

    private

    def execute_stack(env, base_implementation)
      return call_implementation(env, base_implementation) unless @middlewares.any?

      @middlewares.each do |middleware|
        middleware.before env if middleware.respond_to? :before
      end

      @middlewares.first._call(env, base_implementation)

      @middlewares.each do |middleware|
        middleware.after env if middleware.respond_to? :after
      end
    end

    def call_implementation(env, base_implementation)
      if middleware = @middlewares.select(&it.respond_to?(:implement)).last
        middleware.implement(env)
      elsif base_implementation
        base_implementation.call env
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

      def _call(env, base_implementation)
        if respond_to? :around
          around(env) { |env|
            _continue env, base_implementation
          }
        else
          _continue env, base_implementation
        end
      end

      def _continue(env, base_implementation)
        if self._next
          self._next._call(env, base_implementation)
        else
          @stack.send :call_implementation, env, base_implementation
        end
      end
    end
  end
end
