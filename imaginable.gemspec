$:.push File.expand_path("../lib", __FILE__)
require "imaginable/version"

Gem::Specification.new do |s|
  s.name        = "imaginable"
  s.version     = Imaginable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Simon Ask Ulsnes", "Thomas Dippel"]
  s.email       = ["simon@ulsnes.dk", "thomasdi@benjamin.dk"]
  s.homepage    = "http://rubygems.org/gems/imaginable"
  s.summary     = "A gem for hooking a rails application up to the imagine image-server."
  s.description = "A gem for hooking a rails application up to the imagine image-server."
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "rails"
  s.add_dependency "uuidtools"
  s.add_dependency "cdnconnect-api"
end
