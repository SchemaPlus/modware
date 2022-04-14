# frozen_string_literal: true

require 'spec_helper'

describe "Env" do

  When(:env) { Modware::Stack.new(env: klass).start(args) {} }

  context "if env: klass is a Class" do

    Given(:klass) { String }
    Given(:args) { "EnvArgs" }

    Then { expect(env).to eq klass.new(args) }

  end

  context "if env: klass is an array of keys" do

    Given(:klass) { [:a, :b, :c] }
    Given(:args) { {a: 1, b: 2, c: 3} }

    Then { expect(env.to_hash).to eq args }
  end

  context "if env: klass is an array of keys with nils in args" do

    Given(:klass) { [:a, :b, :c] }
    Given(:args) { {a: 1, b: 2, c: nil} }

    Then { expect(env.to_hash).to eq args }
  end

end
