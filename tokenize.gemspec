# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tokenize/version"

Gem::Specification.new do |s|
  s.name        = "msp_tokenize"
  s.version     = Tokenize::VERSION
  s.authors     = ["Tom Dunning"]
  s.email       = ["tom.dunning@isotopedev.com"]
  s.homepage    = ""
  s.summary     = %q{url token encoding & decoding}
  s.description = %q{url token encoding & decoding using Base64, SHA1 and AES}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"

  # s.add_runtime_dependency "yaml"
end