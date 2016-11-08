# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'api_sampler/version'

Gem::Specification.new do |spec|
  spec.name          = 'api_sampler'
  spec.version       = ApiSampler::VERSION
  spec.authors       = ['K. Volchenko']
  spec.email         = ['likeath@gmail.com']
  spec.summary       = 'Sample api requests'
  spec.description   = 'Sample api requests'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'oj'
  spec.add_runtime_dependency 'redis'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
end
