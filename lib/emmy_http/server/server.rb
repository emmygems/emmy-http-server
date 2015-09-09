require "emmy_http/server/version"

module EmmyHttp
  class Server::Server
    using EventObject

    attr_accessor :config
    attr_accessor :app
    attr_accessor :connections
    attr_accessor :parser

    events :connect, :request, :error

    def initialize(config, app=nil)
      @config = config
      @app = app
      @connections = []

      if app
        on :request do |req, res|
          req.prepare_env
          res.status, res.headers, res.body = app.call(req.env)
        end
      else
        on :request do |req, res|
          error!('No app found', req, res)
        end
      end

      on :error do |reason, req, res|
        if res.headers_sent?
          # big problems
        else
          body = reason ? reason.to_s : 'An error happened'
          res.update_attributes(
            status: 500,
            headers: {
              'Content-Type'   => 'text/plain',
              'Content-Length' => body.bytesize
            },
            body: body
          )
        end
      end
    end

    # initialize a new connection
    def initialize_connection(conn)
      conn.comm_inactivity_timeout = config.timeout.to_i
      conn.start_tls(config.ssl ? config.ssl.serializable_hash : {}) if ssl?
      # Create a new request
      req = new_request(conn)
      # Connected event
      connect!(req, conn)
    end

    def new_request(conn)
      req = Server::Request.new(
        #decoder: config.decoding ? new_decoder_by_encoding(headers['Content-Encoding']) : nil
      )

      req.on :complete do |req, conn|
        res = Server::Response.new
        res.keep_alive = req.keep_alive?
        res.attach(conn)

        EmmyMachine.fiber_block do
          # Process request event
          begin
            request!(req, res)
          rescue StandardError => err
            error!(err, req, res)
          end

          # Send response
          res.write_all
          # Close/Dettach response
          res.close
          # Disconnect after response
          if res.keep_alive
            new_request(conn)
          else
            conn.close_connection_after_writing
          end
        end
      end

      req.on :error do |reason, req, conn|
        error!(reason)
        conn.close_connection_after_writing rescue nil
      end

      req.attach(conn)
      req
    end

    def ssl?
      config.ssl || config.url.scheme == 'https' || config.url.port == 443
    end

    #def stop(reason=nil)
    #  @stop_reason ||= reason
    #  connection.close_connection if connection
    #end

    def to_a
      [config.url, EmmyMachine::Connection, method(:initialize_connection)]
    end

    #<<<
  end
end
