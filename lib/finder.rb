require "singleton"
require "relaton"
require "./lib/db"

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

module Relaton
  class Finder
    include Singleton

    def initialize
      Relaton.configure do |config|
        config.use_api = false
      end

      @db = Relaton::Db.init_bib_caches global_cache: true
    end

    def fetch(code, year, opts)
      @db.fetch code, year, opts
    end
  end
end
