require 'bundler/setup'
require 'emmy'
require 'emmy_http/server'
require './app'
using EventObject

Emmy.run do
  app = EmmyHttp::Application.new do
    run Sinatra::Application
  end

  server = EmmyHttp::Server::Server.new(Emmy::Runner.instance.config, app)

  Emmy.bind(*server)
  puts "Bind server on #{server.config.url}"

  server.on :error do |err|
    puts err.message
    puts err.backtrace.join("\n")
  end
end
