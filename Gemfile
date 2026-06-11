# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# gem "aws-partitions", "~> 1.613.0"
gem "aws-sdk-s3", "~> 1.188"
gem "relaton", ENV["RELATION_GEM_VERSION"] || "~> 2.1.0"

group :test do
  gem "rspec"
  gem "simplecov"
  gem "vcr"
  gem "webmock"
end
