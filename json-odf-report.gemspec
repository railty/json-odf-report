# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "json-odf-report/version"

Gem::Specification.new do |s|
  s.name = %q{json-odf-report}
  s.version = JODFReport::VERSION

  s.authors = ["Shawn Ning"]
  s.description = %q{Generates ODF files, given a template (.odt) and a json object, replacing tags by the data in json}
  s.email = %q{zxning@gmail.com}
  #s.has_rdoc = false
  s.homepage = %q{http://railty.github.com/json-odf-report/}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Generates ODF files, using an ODT template and a json object, replacing tags by the data in json}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency('rubyzip', "~> 0.9.9")
  s.add_runtime_dependency('nokogiri', ">= 1.10.2")

end
