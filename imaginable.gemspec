$:.push File.expand_path("../lib", __FILE__)
require "imaginable/version"

Gem::Specification.new do |s|
  s.name        = "imaginable"
  s.version     = Imaginable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Dippel"]
  s.email       = ["thomasdi@benjamin.dk"]
  s.homepage    = "http://rubygems.org/gems/imaginable"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "imaginable"
  
  s.require_paths = ["lib"]
  
  s.add_dependency "rails", "3.0.5"
  s.add_dependency "uuidtools"
end
