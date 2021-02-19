require "singleton"
require "relaton"

module Relaton
  class Finder
    include Singleton

    def initialize
      Relaton.configure do |config|
        config.use_api = false
      end

      @db = Relaton::Db.new "gcache", "lcache"
    end

    def fetch(code, year, opts)
      @db.fetch code, year, opts
    end
  end
end
