source "https://rubygems.org"

gemspec

group :docs do
  gem "yard"
  gem "redcarpet"
  gem "github-markup"
end

group :test do
  gem "chefstyle"
  gem "rspec-core", "~> 3.2"
  gem "rspec-mocks", "~> 3.2"
  gem "rspec-expectations", "~> 3.2"
  gem "rake"
  gem "mixlib-log", "~> 2"
  gem "net-ssh"
end

group :development do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer"
  gem "rb-readline"
end

instance_eval(ENV["GEMFILE_MOD"]) if ENV["GEMFILE_MOD"]

# If you want to load debugging tools into the bundle exec sandbox,
# add these additional dependencies into Gemfile.local
eval_gemfile(__FILE__ + ".local") if File.exist?(__FILE__ + ".local")
