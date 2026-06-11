# frozen_string_literal: true

require "singleton"
require "relaton"

Relaton::Registry.instance

require_relative "../../override/relaton/db"

module Relaton
  class Api
    class Finder
      include Singleton

      def initialize
        Relaton.configure { |config| config.use_api = false }
        @db = Relaton::Db.init_bib_caches global_cache: true
      end

      def fetch(code, year = nil, opts = {})
        @db.fetch(code, year, opts)
      end
    end
  end
end
