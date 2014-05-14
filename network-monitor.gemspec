# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'network/monitor/version'

Gem::Specification.new do |spec|
	spec.name          = "network-monitor"
	spec.version       = Network::Monitor::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]
	spec.summary       = %q{A tool for monitoring network ports for both throughput and errors.}
	spec.homepage      = ""
	spec.license       = "MIT"
	
	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]
	
	spec.add_dependency "snmp", "~> 1.1.1"
	spec.add_dependency "trollop", "~> 2.0.0"
	
	spec.add_dependency "rainbow", '~> 2.0.0'
	
	spec.add_development_dependency "bundler", "~> 1.3"
	spec.add_development_dependency "rake"
end
