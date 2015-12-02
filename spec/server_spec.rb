require 'xmlrpc/scgi'

describe XMLRPC::SCGIServer do
  before(:each) do
    @server = XMLRPC::SCGIServer.new 'fake socket'
  end

  context '.read_netstring' do
    it 'Valid netstring' do
      expect(@server.read_netstring(StringIO.new('5:hello,'))).to eql('hello')
    end

    it 'Invalid netstring - missing end comma' do
      expect do
        @server.read_netstring(StringIO.new('5:hello'))
      end.to raise_error(RuntimeError)
    end

    it 'Invalid netstring - invalid length' do
      expect do
        @server.read_netstring(StringIO.new('53457254754754:hello,'))
      end.to raise_error(RuntimeError)
    end
  end

  it '.write_netstring' do
    expect(@server.write_netstring('hello')).to eql('5:hello,')
  end

  context '.split_request' do
    before(:each) do
      @request = [
        'CONTENT_LENGTH',
        '56',
        'SCGI',
        '1',
        'REQUEST_METHOD',
        'POST',
        'REQUEST_URI',
        '/deepthought'
      ]

      @body = 'What is the answer to life, the Universe and everything?'
    end

    it 'Valid request' do
      netstring = @server.write_netstring("#{@request.join("\0")}")
      expect(@server.split_request(StringIO.new("#{netstring}#{@body}")))
        .to eql([Hash[*@request], @body])
    end

    it 'Invalid request - short body' do
      netstring = @server.write_netstring("#{@request[0..-3].join("\0")}")
      expect(@server.split_request(StringIO.new("#{netstring}#{@body}")))
        .to_not eql([Hash[*@request], @body])
    end
  end

  it 'should spool up a server' do
    server_thread = Thread.new do
      server = XMLRPC::SCGIServer.new '127.0.0.1:6000'
      server.serve
    end
    expect(server_thread.status).to be_a(String)
    Thread.kill server_thread
  end
end
