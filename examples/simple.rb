require 'bundler/setup'
require 'emmy_machine'
require 'emmy_http'
require 'emmy_http/server'
require './app'
using EventObject

# Without emmy engine
module Emmy
  extend EmmyMachine::ClassMethods
  include EventObject
  include Fibre::Synchrony
end

Emmy.run do
  app = ::Rack::Builder.app do
    run Sinatra::Application
  end

  config = EmmyHttp::Configuration.new
  server = EmmyHttp::Server::Server.new(config, app)

  Emmy.bind(*server)
  puts "Bind server on #{server.config.url}"

  server.on :error do |err|
    puts err.message
    puts err.backtrace.join("\n")
  end
end
