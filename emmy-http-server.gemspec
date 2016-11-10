# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emmy_http/server/version'

Gem::Specification.new do |spec|
  spec.name          = 'emmy-http-server'
  spec.version       = EmmyHttp::Server::VERSION
  spec.authors       = ['Maksim V.']
  spec.email         = ['inre.storm@gmail.com']

  spec.summary       = %q{Emmy HTTP Server}
  spec.description   = %q{EventMachine-based HTTP server}
  spec.homepage      = 'https://github.com/emmygems'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version     = '>= 2.2.2'
  spec.required_rubygems_version = '>= 2.3.0'

  spec.add_dependency 'http_parser.rb', '~> 0.6.0'
  spec.add_dependency 'addressable', '~> 2.5'
  spec.add_dependency 'event_object', '~> 1'
  spec.add_dependency 'fibre', '~> 1'
  spec.add_dependency 'emmy-machine', '~> 0.4'
  spec.add_dependency 'emmy-http', '~> 0.4'

  spec.add_development_dependency 'eventmachine', '~> 1'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake',    '~> 10'
  spec.add_development_dependency 'rspec',   '~> 3'
end
