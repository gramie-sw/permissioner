# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'permissioner/version'

Gem::Specification.new do |gem|
  gem.name = "permissioner"
  gem.version = Permissioner::VERSION
  gem.authors = ["Daniel Grawunder, Christian Mierich"]
  gem.email = ["gramie.sw@gmail.com"]
  gem.homepage = "https://github.com/gramie-sw/permissioner"
  gem.description = %q{A Ruby on  Rails authorization gem}
  gem.summary = %q{An easy to use authorization solution for Ruby on Rails.}
  gem.license = "EPL 1.0"

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rspec", "~>2.14.1"
  gem.add_development_dependency "activesupport", "~>4.0.2"
  gem.add_development_dependency "actionpack", "~>4.0.2"
  gem.add_development_dependency "guard-rspec", "~>4.2.0"
end
