# frozen_string_literal: true

require 'spec_helper'

describe "Helper" do

  let(:none) { { before: nil, after:nil, around: nil, implement: nil } }

  context "Modware.is_middleware?" do
    [:before, :after, :around, :implement].each do |method|
      it "returns truthy for a module with #{method.inspect} method" do
        expect(Modware.is_middleware? Factory.middleware(**none.merge(method => true))).to be_truthy
      end
    end

    it "returns falsey for other modules" do
      expect(Modware.is_middleware? Factory.middleware(**none.merge(other: true))).to be_falsey
    end
  end

end
