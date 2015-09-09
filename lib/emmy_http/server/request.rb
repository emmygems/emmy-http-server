module EmmyHttp
  class Server::Request
    include ModelPack::Document
    using EventObject

    attribute :http_version
    attribute :http_method
    attribute :url,
          writer:    -> (v) { Addressable::URI.parse(v) },
          serialize: -> (v) { v.to_s }
    dictionary :headers
    attribute :body
    attribute :decoder
    attribute :env
    #attribute :upgrade_data

    attr_reader :connection
    attr_reader :parser
    attr_reader :request
    attr_reader :remote_address

    events :data, :complete, :terminate

    def initialize
      @parser = Server::Parser.new
      @body   = StringIO.new(Server::INITIAL_BODY.dup)
      request = self

      on :data do |chunk|
        @body << chunk
      end

      parser.on :head do |headers|
        request.http_version = parser.http_version
        request.http_method  = parser.http_method
        request.url     = parser.request_url
        request.headers = parser.headers
      end

      parser.on :body do |chunk|
        request.data!(request.decoder ? (request.decoder.decompress(chunk) || '') : chunk)
      end

      parser.on :complete do
        conn = request.connection
        dettach
        complete!(request, conn)
      end
    end

    def post_data(chunk)
      #p chunk
      parser << chunk

      #if parser.upgrade?
      #end
    rescue EmmyHttp::ParserError => e
      close(e.message)
    end

    def keep_alive?
      #return false if terminate_connection?
      case http_version
      when [1,0] then
        (headers['Connection'].downcase == 'keep-alive') rescue false
      when [1,1] then
        (headers['Connection'].downcase != 'close') rescue true
      when [2,0] then
        false
      else
        false
      end
    end

    def prepare_env
      @env = {}

      # Server info

      @env['rack.version']      = Server::RACK_VERSION_NUM
      @env['rack.errors']       = STDERR
      @env['rack.multithread']  = false
      @env['rack.multiprocess'] = false
      @env['rack.run_once']     = false
      #env['rack.logger']       = logger

      # HTTP headers

      headers.each do |n, v|
        @env['HTTP_' + n.gsub('-','_').upcase] = v
      end

      %w(CONTENT_TYPE CONTENT_LENGTH).each do |n|
        @env[n] = @env.delete("HTTP_#{n}") if @env["HTTP_#{n}"]
      end

      @env['SERVER_NAME']       = 'localhost'
      @env['SERVER_SOFTWARE']   = Server::SERVER_NAME

      if @env['HTTP_HOST'] # FIXME
        name, port = @env['HTTP_HOST'].split(':')
        @env['SERVER_NAME'] = name if name
        @env['SERVER_PORT'] = port if port
      end

      uri = URI(parser.request_url)

      @env['HTTP_VERSION']    = "HTTP/#{http_version.join('.')}"
      @env['REMOTE_ADDR']     = remote_address
      @env['REQUEST_METHOD']  = http_method
      @env['REQUEST_URI']     = url.to_s
      @env['QUERY_STRING']    = url.query# || ""
      @env['SCRIPT_NAME']     = ""
      @env['REQUEST_PATH']    = url.path
      @env['PATH_INFO']       = url.path
      @env['FRAGMENT']        = url.fragment

      # HTTP body

      @env['rack.input'] = body
    end

    def close(reason=nil)
      terminate!(reason, self, connection) if reason
      dettach
    end

    def attach(conn)
      @connection = conn
      @remote_address = socket_address
      listen conn, :data,  :post_data
      listen conn, :close, :close
    end

    def dettach
      if connection
        stop_listen connection, :data
        stop_listen connection, :close
        @connection = nil
      end
    end

    protected

    def socket_address
      Socket.unpack_sockaddr_in(connection.get_peername)[1]
    rescue Exception
      nil
    end

    #<<<
  end
end
