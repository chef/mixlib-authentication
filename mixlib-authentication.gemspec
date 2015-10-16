MIXLIB_AUTHN_VERSION = '1.4.0'

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
  s.add_dependency "net-ssh"
  
  s.require_path = 'lib'
  s.files = %w(LICENSE README.rdoc Gemfile Rakefile NOTICE) + Dir.glob("*.gemspec") +
      Dir.glob("{lib,spec}/**/*", File::FNM_DOTMATCH).reject {|f| File.directory?(f) }
end

