# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "status_page/version"

Gem::Specification.new do |spec|
  spec.name          = "status-page"
  spec.version       = StatusPage::VERSION
  spec.authors       = ["Mohamed Sobhy Fouda"]
  spec.email         = ["m.fouda@robone.net"]
  spec.description   = %q{Status-Page Cli help you to monitor servers status }
  spec.summary       = %q{ For more information check help files and Read me}
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
  spec.add_dependency "json"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
