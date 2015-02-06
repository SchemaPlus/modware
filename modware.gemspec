# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'modware/version'

Gem::Specification.new do |spec|
  spec.name          = "modware"
  spec.version       = Modware::VERSION
  spec.authors       = ["ronen barzel"]
  spec.email         = ["ronen@barzel.org"]
  spec.summary       = %q{A middleware library, featuring a simple interface and "callback" style semantics in the middleware stack}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "key_struct", "~> 0.4"
  spec.add_dependency "its-it"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-given"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-gem-profile"
end
