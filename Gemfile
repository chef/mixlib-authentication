source "https://rubygems.org"

gemspec

group :docs do
  gem "github-markup"
  gem "redcarpet"
  gem "yard"
end

group :test do
  gem "chefstyle"
  gem "mixlib-log", "~> 3"
  gem "net-ssh"
  gem "rake"
  gem "rspec-core", "~> 3.2"
  gem "rspec-expectations", "~> 3.2"
  gem "rspec-mocks", "~> 3.2"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "pry-stack_explorer", "~> 0.4.0" # pin until we drop ruby < 2.6
  gem "rb-readline"
end
