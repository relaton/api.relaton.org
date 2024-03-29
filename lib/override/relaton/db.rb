require_relative "db_cache"

module Relaton
  class Db
    # @param global_cache [String] directory of global DB
    # @param local_cache [String] directory of local DB
    def initialize(global_cache, local_cache)
      @registry = Relaton::Registry.instance
      @db = open_cache_biblio(global_cache, type: :global)
      @local_db = open_cache_biblio(local_cache, type: :local)
      # @static_db = open_cache_biblio "static_cache"
      @queues = {}
    end

    private

    # @param dir [String, nil] DB directory
    # @param type [Symbol]
    # @return [Relaton::DbCache, NilClass]
    def open_cache_biblio(dir, type: :static) # rubocop:disable Metrics/MethodLength
      return nil if dir.nil?

      db = DbCache.new dir, type == :static ? "yml" : "xml"
      return db if type == :static

      db.check_all_versions?
      db
    end

    class << self
      private

      def global_bibliocache_name
        "cache"
      end

      def local_bibliocache_name(_cachename)
        nil
      end
    end
  end
end
