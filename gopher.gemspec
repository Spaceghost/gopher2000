# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gopher/version"

Gem::Specification.new do |s|
  s.name        = "gopher"
  s.version     = Gopher::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Colin Mitchell"]
  s.email       = ["colin@muffinlabs.com"]
  s.homepage    = "http://muffinlabs.com"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "gopher"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "rdoc"
  s.add_runtime_dependency "eventmachine"
  s.add_runtime_dependency "logger"

  # s.add_runtime_dependency "rest-client"
end
