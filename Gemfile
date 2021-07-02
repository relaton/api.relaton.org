# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# gem "relaton", "1.8.pre2"
gem "relaton", ENV["RELATION_GEM_VERSION"] || "1.8.pre2"

group :test do
  gem "rspec"
  gem "simplecov"
  gem "vcr"
  gem "webmock"
end
