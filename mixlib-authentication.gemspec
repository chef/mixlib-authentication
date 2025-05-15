$:.unshift(__dir__ + "/lib")
require "mixlib/authentication/version"

Gem::Specification.new do |s|
  s.name = "mixlib-authentication"
  s.version = Mixlib::Authentication::VERSION
  s.summary = "Mixes in simple per-request authentication"
  s.description = s.summary
  s.license = "Apache-2.0"
  s.author = "Chef Software, Inc."
  s.email = "info@chef.io"
  s.homepage = "https://github.com/chef/mixlib-authentication"
  s.required_ruby_version = ">= 3.1"

  s.files = %w{LICENSE} + Dir.glob("lib/**/*")
  s.require_paths = ["lib"]
  s.add_dependency "logger"  # logger, ostruct, fiddle, and base64 are part of the stdlib and are being removed in ruby 3.5 so they must be included in the gemspec
  s.add_dependency "ostruct"
  s.add_dependency "fiddle"
  s.add_dependency "base64"
  s.add_development_dependency "cookstyle", "~> 8.1"
end
