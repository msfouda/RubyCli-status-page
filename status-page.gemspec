# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "status_page/version"

Gem::Specification.new do |spec|
  spec.name          = "status-page"
  spec.version       = StatusPage::VERSION
  spec.authors       = ["Tung Nguyen"]
  spec.email         = ["tongueroo@gmail.com"]
  spec.description   = %q{i am description}
  spec.summary       = %q{i am summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "colorize"
  spec.add_dependency "httparty"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
