module EmmyHttp
  class Server::Response
    include ModelPack::Document
    using EventObject

    attribute :status, writer: -> (v) { v ? v.to_i : v }
    dictionary :headers
    attribute :body

    events :terminate

    attr_accessor :keep_alive
    attr_accessor :connection
    attr_writer :headers_sent
    attr_writer :finished

    def write_all
      write_head unless headers_sent?
      write_body unless finished?
    end

    def write_head
      raise ResponseError, "Invalid HTTP status" unless Server::HTTP_STATUS_CODES.key?(status)

      prepare_headers
      head = "HTTP/1.1 #{status} #{Server::HTTP_STATUS_CODES[status.to_i]}\r\n"

      headers.each do |n, v|
        head += "#{n}: #{v}\r\n" if v
      end

      head += "\r\n"

      connection.send_data(head)
      @headers_sent = true
    end

    def write_body
      if body.respond_to?(:each)
        body.each { |chunk| connection.send_data(chunk) }
      else
        connection.send_data(body) if body
      end
      @finished = true
    end

    def close(reason=nil)
      body.close if body.respond_to?(:close)
      terminate!(reason, self, connection) if reason
      dettach
    end

    def attach(conn)
      @connection = conn
      listen conn, :close, :close
    end

    def dettach
      if connection
        stop_listen connection, :close
        @connection = nil
      end
    end

    def headers_sent?
      @headers_sent
    end

    def finished?
      @finished
    end

    protected

    def prepare_headers
      headers['Server'] ||= Server::SERVER_NAME
      headers['Date'] ||= Time.now.httpdate
      headers['Connection'] = keep_alive ? 'keep-alive' : 'close'
      #headers['Content-Length'] ||= "#{body.bytesize}" if body
    end

    #<<<
  end
end
