# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emmy_http/server/version'

Gem::Specification.new do |spec|
  spec.name          = "emmy-http-server"
  spec.version       = EmmyHttp::Server::VERSION
  spec.authors       = ["inre"]
  spec.email         = ["inre.storm@gmail.com"]

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "http_parser.rb", "~> 0.6.0"
  spec.add_dependency "addressable",    "~> 2.3.8"
  spec.add_dependency "event_object",   "~> 0.9"
  spec.add_dependency "fibre",          "~> 0.9"
  spec.add_dependency "emmy-machine",   "~> 0.1"
  spec.add_dependency "emmy-http",      "~> 0.2"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake",    "~> 10.0"
  spec.add_development_dependency "rspec",   "~> 3"
end
