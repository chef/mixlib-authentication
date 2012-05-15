require 'rubygems'
require 'rake/gempackagetask'
require 'rubygems/specification'
require 'date'
require 'rspec/core/rake_task'

GEM = "mixlib-authentication"
GEM_VERSION = "1.2.1"
AUTHOR = "Opscode, Inc."
EMAIL = "info@opscode.com"
HOMEPAGE = "http://www.opscode.com"
SUMMARY = "Mixes in simple per-request authentication"

task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = %w(-fs --color)
end

gem_spec = eval(File.read("mixlib-authentication.gemspec"))

Rake::GemPackageTask.new(gem_spec) do |pkg|
  pkg.gem_spec = gem_spec
end

desc "install the gem locally"
task :install => [:package] do
  sh %{gem install pkg/#{GEM}-#{GEM_VERSION}}
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{GEM}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "remove build files"
task :clean do
  sh %Q{ rm -f pkg/*.gem }
end

desc "Run the spec and features"
task :test => [ :features, :spec ]
