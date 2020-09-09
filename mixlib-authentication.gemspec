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
  s.required_ruby_version = ">= 2.4"

  s.files = %w{LICENSE} + Dir.glob("lib/**/*")
  s.require_paths = ["lib"]
end
