# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xmlrpc/scgi/version'

Gem::Specification.new do |spec|
  spec.name          = "xmlrpc-scgi"
  spec.version       = XMLRPC::SCGI::VERSION
  spec.authors       = ["Stephen Muth"]
  spec.email         = ["smuth4@gmail.com"]
  spec.summary       = %q{Extend XMLRPC with an SCGI client and server.}
  spec.description   = %q{Extend XMLRPC with an SCGI client and server.}
  spec.homepage      = "https://github.com/smuth4/ruby-xmlrpc-scgi"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rubocop", "~> 0.35"
end
