# frozen_string_literal: true

module Factory
  def self.middleware(n=nil, before: true, after: true, around: true, implement: true, other: nil)

    methods = []

    methods << (before && <<-END)
      def before(env)
        env.result << :"before#{n}"
      end
    END

    methods << (after && <<-END)
      def after(env)
        env.result << :"after#{n}"
      end
    END

    methods << (around && <<-END)
      def around(env)
        env.result << :"around_pre#{n}"
        yield env
        env.result << :"around_post#{n}"
      end
    END

    methods << (implement && <<-END)
      def implement(env)
        env.result << :"implement#{n}"
      end
    END

    methods << (other && <<-END)
      def other(env)
        env.result << :"other#{n}"
      end
    END

    Module.new do
      module_eval(methods.compact.join)
    end
  end
end
