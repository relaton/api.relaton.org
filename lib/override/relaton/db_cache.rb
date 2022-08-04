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
      @storage.save_version prefix_dir, self.class.grammar_hash(prefix_dir)
      @storage.save file, value
    end

    # Returns all items
    # @return [Array<String>]
    def all(&block)
      @storage.all(@dir, &block)
    end

    # Delete item
    # @param key [String]
    def delete(key)
      f = @storage.search_ext(key)
      f && @storage.delete(filename(f))
    end

    # Check if version of the DB match to the gem grammar hash.
    # @param fdir [String] dir pathe to flover cache
    # @return [Boolean]
    def check_version?(fdir)
      @storage.get_version(fdir) == self.class.grammar_hash(fdir)
    end

    #
    # Check all flavors version and clean cahce from invalid documents
    #
    # @return [<Type>] <description>
    #
    def check_all_versions?
      files = @storage.ls_dir(@dir).reduce([]) do |a, fd|
        next a if check_version?(fd) == self.class.grammar_hash(fd)

        a + @storage.ls(fd)
      end
      @storage.delete files
    end

    # Reads file by a key
    #
    # @param key [String]
    # @return [String, nil]
    def get(key)
      if @ext == "yml"
        super
      else
        return unless (f = @storage.search_ext(filename(key)))

        @storage.get f
      end
    end
  end

  class DbCache
    prepend DbCacheExt
  end
end
