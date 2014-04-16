$:.push File.expand_path("../lib", __FILE__)
require "lightpack/version"

Gem::Specification.new do |s|
  s.name          = "lightpack"
  s.version       = Lightpack::VERSION

  s.platform      = Gem::Platform::RUBY
  s.author        = "Douwe Maan"
  s.email         = "douwe@selenight.nl"
  s.homepage      = "https://github.com/DouweM/lightpack"
  s.description   = "A Ruby library for communicating with your Lightpack."
  s.summary       = "Lightpack communication library"
  s.license       = "MIT"

  s.files         = Dir.glob("lib/**/*") + %w(LICENSE README.md Rakefile Gemfile)
  s.test_files    = Dir.glob("spec/**/*")
  s.require_path  = "lib"
  
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end