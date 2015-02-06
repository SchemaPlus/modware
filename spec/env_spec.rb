require 'spec_helper'

describe "Env" do

  When(:env) { Modware::Stack.new(env_class).start(env_args) {} }

  context "if env_class is a Class" do

    Given(:env_class) { String }
    Given(:env_args) { "EnvArgs" }

    Then { expect(env).to eq env_class.new(env_args) }

  end

  context "if env_class is an array of keys" do

    Given(:env_class) { [:a, :b, :c] }
    Given(:env_args) { {a: 1, b: 2, c: 3} }

    Then { expect(env.to_hash).to eq env_args }
  end

end
