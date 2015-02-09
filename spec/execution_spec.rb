require 'spec_helper'

describe "Execution" do

  Given(:stack) { Modware::Stack.new(env: [:result]) }

  context "when start with no implementation" do

    When(:env) { stack.start result: [] }

    Then { expect(env).to have_failed(Modware::StackError, /implementation/) }
  end

  context "when start with base implementation" do

    When(:env) { stack.start result: [] { |env| env.result << :base } }

    Then { expect(env.result).to eq [:base] }

    context "if add middleware1" do

      Given { stack.add Factory.middleware(1, around: nil) }

      Then { expect(env.result).to eq [:before1, :implement1, :after1 ] }

      context "if add middleware2" do

        Given { stack.add Factory.middleware(2, implement: nil) }

        Then { expect(env.result).to eq [:before1, :before2, :around_pre2, :implement1, :around_post2, :after1, :after2 ] }
      end
    end

  end

end
