require 'xmlrpc/scgi'

describe XMLRPC::SCGIClient do
  before(:all) do
    @server_thread = Thread.new do
      server = XMLRPC::SCGIServer.new '127.0.0.1:6000'
      server.add_handler('add') do |a, b|
        a + b
      end
      server.serve
    end
    @client = XMLRPC::SCGIClient.new '127.0.0.1', '', 6000
  end

  after(:all) do
    Thread.kill @server_thread
    @server_thread.join
  end

  it 'should perform calls' do
    expect(@client.call('add', 4, 5)).to be(4 + 5)
  end

  it 'should handle big ints calls' do
    expect(@client.call('add', 2**(4 * 8), 5)).to be(2**(4 * 8) + 5)
  end
end
