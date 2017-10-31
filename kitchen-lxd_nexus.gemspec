# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/driver/lxd/version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-lxd_nexus'
  spec.version       = Kitchen::Driver::LXD::VERSION
  spec.authors       = ['Sean Zachariasen']
  spec.email         = ['thewyzard@hotmail.com']

  spec.summary       = 'Test Kitchen Driver for LXD'
  spec.homepage      = 'https://github.com/NexusSW/kitchen-lxd_nexus'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'lxd-common', '~> 0.1'
  spec.add_dependency 'test-kitchen'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
