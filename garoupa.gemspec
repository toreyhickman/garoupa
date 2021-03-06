# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'garoupa/version'

Gem::Specification.new do |spec|
  spec.name          = "garoupa"
  spec.version       = Garoupa::VERSION
  spec.authors       = ["Torey Hickman"]
  spec.email         = ["torey@toreyhickman.com"]
  spec.summary       = %q{Make groups from a list}
  spec.homepage      = "https://github.com/toreyhickman/garoupa"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "json"
end
