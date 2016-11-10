require 'event_object'
require 'model_pack'
require 'emmy_http/server/version'
require 'emmy_http/server/parser'
require 'emmy_http/server/request'
require 'emmy_http/server/response'
require 'emmy_http/server/server'

module EmmyHttp
  module Server
    INITIAL_BODY = ''
    INITIAL_BODY.encode!(::Encoding::ASCII_8BIT) if INITIAL_BODY.respond_to?(:encode)

    SERVER_NAME         = 'Emmy'.freeze
    RACK_VERSION_NUM    = [1, 0]

    HTTP_STATUS_CODES = {
      100 => 'Continue',
      101 => 'Switching Protocols',
      200 => 'OK',
      201 => 'Created',
      202 => 'Accepted',
      203 => 'Non-Authoritative Information',
      204 => 'No Content',
      205 => 'Reset Content',
      206 => 'Partial Content',
      300 => 'Multiple Choices',
      301 => 'Moved Permanently',
      302 => 'Moved Temporarily',
      303 => 'See Other',
      304 => 'Not Modified',
      305 => 'Use Proxy',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      402 => 'Payment Required',
      403 => 'Forbidden',
      404 => 'Not Found',
      405 => 'Method Not Allowed',
      406 => 'Not Acceptable',
      407 => 'Proxy Authentication Required',
      408 => 'Request Time-out',
      409 => 'Conflict',
      410 => 'Gone',
      411 => 'Length Required',
      412 => 'Precondition Failed',
      413 => 'Request Entity Too Large',
      414 => 'Request-URI Too Large',
      415 => 'Unsupported Media Type',
      500 => 'Internal Server Error',
      501 => 'Not Implemented',
      502 => 'Bad Gateway',
      503 => 'Service Unavailable',
      504 => 'Gateway Time-out',
      505 => 'HTTP Version not supported'
    }
  end
end
