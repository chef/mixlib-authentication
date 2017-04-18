require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "mixlib/authentication/version"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Run tests for Travis CI"
task ci: [:style, :spec]

begin
  require "chefstyle"
  require "rubocop/rake_task"
  RuboCop::RakeTask.new(:style) do |task|
    task.options += ["--display-cop-names", "--no-color"]
  end
rescue LoadError
  puts "chefstyle/rubocop is not available.  gem install chefstyle to do style checking."
end

begin
  require "github_changelog_generator/task"

  GitHubChangelogGenerator::RakeTask.new :changelog do |config|
    config.issues = false
    config.future_release = Mixlib::Authentication::VERSION
  end
rescue LoadError
  puts "github_changelog_generator is not available. gem install github_changelog_generator to generate changelogs"
end
