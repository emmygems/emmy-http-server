require 'http/parser'

module EmmyHttp
  class Server::Parser
    using EventObject

    events :head, :body, :complete

    attr_accessor :http_parser
    attr_accessor :stop
    attr_accessor :no_body

    def initialize
      @http_parser = HTTP::Parser.new
      @http_parser.header_value_type = :mixed
      @http_parser.on_headers_complete = proc do
        head!(http_parser.headers, http_parser)
        stop ? :stop : (no_body ? :reset : nil)
      end
      @http_parser.on_body = proc do |chunk|
        body!(chunk)
      end
      @http_parser.on_message_complete = proc do
        complete!
      end
    end

    def <<(data)
      @http_parser << data
    rescue HTTP::Parser::Error => e
      raise EmmyHttp::ParserError, e.to_s
    end

    def status_code
      @http_parser.status_code
    end

    def http_method
      @http_parser.http_method
    end

    def headers
      @http_parser.headers
    end

    def http_version
      @http_parser.http_version
    end

    def request_url
      @http_parser.request_url
    end

    def reset!
      @http_parser.reset!
    end

    #<<<
  end
end
