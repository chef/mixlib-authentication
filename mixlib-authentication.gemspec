MIXLIB_AUTHN_VERSION = '1.2'

Gem::Specification.new do |s|
  s.name = "mixlib-authentication"
  s.version = MIXLIB_AUTHN_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE", 'NOTICE']
  s.summary = "Mixes in simple per-request authentication"
  s.description = s.summary
  s.author = "Opscode, Inc."
  s.email = "info@opscode.com"
  s.homepage = "http://www.opscode.com"
  
  # Uncomment this to add a dependency
  s.add_dependency "mixlib-log"
  
  s.require_path = 'lib'
  s.files = %w(LICENSE README.rdoc Rakefile NOTICE) + Dir.glob("{lib,spec}/**/*")
end

