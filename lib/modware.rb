# frozen_string_literal: true

require "modware/errors"
require "modware/stack"
require "modware/version"

module Modware
  def self.is_middleware?(mod)
    (mod.instance_methods & [:before, :around, :after, :implement]).any?
  end
end
