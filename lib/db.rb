require "./lib/db_cache"

module Relaton
  class Db
    # @param global_cache [String] directory of global DB
    # @param local_cache [String] directory of local DB
    def initialize(global_cache, local_cache)
      @registry = Relaton::Registry.instance
      @db = open_cache_biblio(global_cache, type: :global)
      @local_db = open_cache_biblio(local_cache, type: :local)
      @static_db = open_cache_biblio File.expand_path "../relaton/static_cache", __dir__
      @queues = {}
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
