source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby ENV["RUBY_VERSION"] || "2.7.1"

gem "active_model_serializers", "~> 0.10.0"
gem "autoprefixer-rails"
gem "bootsnap", "~> 1.4.6", require: false
gem "daemons"
gem "delayed_job_active_record"
gem "honeybadger"
gem "oj"
gem "pg"
gem "puma"
gem "rack-canonical-host"
gem "rails", "~> 5.2.3"
gem "recipient_interceptor"
gem "relaton"
gem "sassc-rails"
gem "skylight"
gem "simple_form"
gem "sprockets", ">= 3.0.0"
gem "title"
gem "uglifier"
gem "rack-timeout", group: :production

group :development do
  gem "listen"
  gem "rack-mini-profiler", require: false
  gem "spring"
  gem "web-console"
  gem "spring-commands-rspec"
end

group :development, :test do
  gem "awesome_print"
  gem "bundler-audit", ">= 0.5.0", require: false
  gem "bullet"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails", "~> 3.6"
  gem "suspenders"
end

group :test do
  gem "capybara-selenium"
  gem "chromedriver-helper"
  gem "formulaic"
  gem "launchy"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
  gem "shoulda-matchers"
end
