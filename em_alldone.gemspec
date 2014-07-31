# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "em_alldone" # To dynamically load the version string

Gem::Specification.new do |s|
  s.name        = "em_alldone"
  s.version     = EmAlldone::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Paul Cortens"]
  s.email       = "paul@thoughtless.ca"
  s.homepage    = "http://github.com/thoughtless/em_alldone"
  s.summary     = "em_alldone#{EmAlldone::Version::STRING}"
  s.description = "Provides a way to execute a callback when all of a set of deferrables complete."
  s.license = 'MIT'

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = [ 'README.rdoc', 'CHANGELOG.rdoc']
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
