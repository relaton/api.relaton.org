require "./lib/storage"

module Relaton
  module DbCacheExt
    # @param dir [String] DB directory
    def initialize(dir, ext = "xml")
      @dir = dir
      @ext = ext
      @storage = Storage.instance
    end

    # Override method
    # @return [nil]
    def mv(_); end

    # Override method
    def clear; end

    # Save item
    # @param key [String]
    # @param value [String] Bibitem xml serialization
    def []=(key, value)
      if value.nil?
        delete key
        return
      end
      /^(?<pref>[^(]+)(?=\()/ =~ key.downcase
      prefix_dir = "#{@dir}/#{pref}"
      file = "#{filename(key)}.#{ext(value)}"
      @storage.save prefix_dir, file, value
    end

    # Returns all items
    # @return [Array<String>]
    def all(&block)
      @storage.all(@dir, &block)
    end

    # Delete item
    # @param key [String]
    def delete(key)
      @storage.delete filename(key)
    end

    # Check if version of the DB match to the gem grammar hash.
    # @param fdir [String] dir pathe to flover cache
    # @return [Boolean]
    def check_version?(fdir)
      @storage.check_version? fdir
    end

    # Reads file by a key
    #
    # @param key [String]
    # @return [String, NilClass]
    def get(key)
      if @ext == "yml"
        super
      else
        @storage.get filename(key)
      end
    end
  end

  class DbCache
    prepend DbCacheExt
  end
end
