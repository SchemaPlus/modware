# frozen_string_literal: true

module Modware
  class Stack
    def initialize(env:)
      @env_klass = case env
                   when Class then env
                   else
                     Struct.new(*env, keyword_init: true) do
                       def to_hash
                         to_h.compact
                       end
                     end
                   end
      @middleware_mods = []
    end

    def add(mod)
      @middleware_mods << mod
    end

    def start(*args, &base_implementation)
      env = @env_klass.new(*args)
      Executor.new(@middleware_mods).execute(env, base_implementation)
      env
    end

    private

    class Executor
      def initialize(middleware_mods)
        prev = nil
        @middlewares = middleware_mods.map { |mod|
          Middleware.new(self, mod).tap { |middleware|
            prev._modware_next = middleware if prev
            prev = middleware
          }
        }
      end

      def execute(env, base_implementation)
        return call_implementation(env, base_implementation) if @middlewares.empty?

        @middlewares.each do |middleware|
          middleware.before env if middleware.respond_to? :before
        end

        @middlewares.first._modware_call(env, base_implementation)

        @middlewares.each do |middleware|
          middleware.after env if middleware.respond_to? :after
        end
      end

      def call_implementation(env, base_implementation)
        if middleware = @middlewares.select { |mw| mw.respond_to?(:implement) }.last
          middleware.implement(env)
        elsif base_implementation
          base_implementation.call env
        else
          raise StackError, "No base implementation nor middleware implementation in stack"
        end
      end
    end


    class Middleware
      attr_accessor :_modware_next

      def initialize(executor, mod)
        @executor = executor
        singleton_class.send :include, mod
      end

      def _modware_call(env, base_implementation)
        if respond_to? :around
          around(env) { |env|
            _modware_continue env, base_implementation
          }
        else
          _modware_continue env, base_implementation
        end
      end

      def _modware_continue(env, base_implementation)
        if self._modware_next
          self._modware_next._modware_call(env, base_implementation)
        else
          @executor.call_implementation env, base_implementation
        end
      end
    end
  end
end
