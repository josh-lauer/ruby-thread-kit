# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'thread_kit/version'

Gem::Specification.new do |spec|
  spec.name          = "thread_kit"
  spec.version       = ThreadKit::VERSION
  spec.authors       = ["Josh Lauer"]
  spec.email         = ["josh.lauer75@gmail.com"]
  spec.summary       = %q{Simple concurrency tools.}
  spec.description   = %q{A simple set of lightweight concurrency tools.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "pry-rescue", "~> 1.4"
  spec.add_development_dependency "pry-byebug", "~> 2.0"
end
