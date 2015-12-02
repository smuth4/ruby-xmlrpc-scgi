require 'pp'
require 'xmlrpc/server'
require 'xmlrpc/client'
require 'xmlrpc/config'

require 'xmlrpc/scgi/version'

module XMLRPC
  # A simple and naive server for serving XMLRPC over the SCGI protocol
  class SCGIServer < XMLRPC::BasicServer
    def initialize(socket, *a)
      @socket = socket
      super(*a)
    end

    def serve
      if @socket.include? ':'
        server = TCPServer.new(*@socket.split(':'))
      else
        server = UNIXServer.new(@socket)
      end
      loop do
        begin
          client = server.accept
          _, body = split_request(client)
          client.write write_http("\n#{process(body)}")
        ensure
          # no matter what we have to put this thread on the bad list
          client.close unless client.nil? || client.closed?
        end
      end
    end

    def write_http(data)
      content = [
        'Status: 200 OK.',
        'Content-Type: text/xml',
        "Content-Length: #{data.length}",
        data
      ]
      content.join "\n\r"
    end

    def read_netstring(handle)
      len = handle.gets(':', 10).sub(':', '')
      payload = handle.read(len.to_i)
      if handle.read(1) == ','
        payload
      else
        fail "Malformed request, does not end with ','"
      end
    end

    def write_netstring(str)
      "#{str.length}:#{str},"
    end

    def split_request(socket)
      return if socket.closed?
      payload = read_netstring socket
      request = Hash[*(payload.split("\0"))]
      fail 'Missing CONTENT_LENGTH' unless request['CONTENT_LENGTH']
      length = request['CONTENT_LENGTH'].to_i
      body = length > 0 ? socket.read(length) : ''
      [request, body]
    end
  end

  # A small derivative class for calling XMLRPC over SCGI
  class SCGIClient < XMLRPC::Client
    def do_rpc(xml, _ = false)
      headers = {
        'CONTENT_LENGTH' => xml.size,
        'SCGI' => 1
      }

      header = "#{headers.to_a.flatten.join("\x00")}"
      request = "#{header.size}:#{header},#{xml}"

      TCPSocket.open(@host, @port) do |s|
        s.write(request)
        s.read.split(/\n\s*?\n/, 2)[1]
      end
    end
  end
end

module XMLRPC
  module XMLParser
    # Overriding the default XML parser
    class AbstractStreamParser
      # A patch for the response method as rtorrent xmlrpc
      # call returns some integers as i8 instead of i4 expected
      # this results in int8 fields showing up with no data
      # as the parse method is not capable of handling such
      # a tag.

      alias_method 'original_parseMethodResponse', 'parseMethodResponse'
      def parseMethodResponse(str) # rubocop:disable Style/MethodName
        str.gsub!(%r{<((\/)*)i8>}, '<\1i4>')
        original_parseMethodResponse(str)
      end
    end
  end
end

module XMLRPC
  # Monkey patch the Create class
  class Create
    alias_method 'original_conv2value', 'conv2value'

    def conv2value(param)
      if ([Fixnum, Bignum].include? param.class) &&
         (param <= -(2**31) || param >= (2**31 - 1))
        cval = @writer.tag('i8', param.to_s)
        @writer.ele('value', cval)
      else
        original_conv2value param
      end
    end
  end
end
