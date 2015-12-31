# XMLRPC::SCGI

[![Build Status](https://travis-ci.org/smuth4/ruby-xmlrpc-scgi.svg)](https://travis-ci.org/smuth4/ruby-xmlrpc-scgi) [![Gem Version](https://badge.fury.io/rb/xmlrpc-scgi.svg)](https://badge.fury.io/rb/xmlrpc-scgi)

A small gem to extend the XMLRPC module by adding an SCGI client and server. It also goes the extra mile and adds support for the non-standard `i8` tag.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xmlrpc-scgi'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scgi-xmlrpc

## Usage

Server
```ruby
require 'xmlrpc/scgi'

server = XMLRPC::SCGIServer.new '127.0.0.1:6000'
server.add_handler('add') do |a, b|
  a + b
end

# Runs until it is killed
server.serve
```

Client
```ruby
require 'xmlrpc/scgi'

client = XMLRPC::SCGIClient.new '127.0.0.1', '', 6000
puts client.call('add', 4, 5)
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/scgi-xmlrpc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
