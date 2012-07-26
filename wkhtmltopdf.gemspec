# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "wkhtmltopdf/version"

Gem::Specification.new do |s|
  s.name        = "wkhtmltopdf"
  s.version     = Wkhtmltopdf::VERSION
  s.authors     = ["Zakir, Keith Morrison"]
  s.email       = ["kleonardmorrison@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Provides binaries for WKHTMLTOPDF in an easily accessible package}
  s.description = %q{See the summary.}

  s.rubyforge_project = "wkhtmltopdf"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
