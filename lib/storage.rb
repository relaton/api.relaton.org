require "aws-sdk-s3"

module Relaton
  #
  # Manage S3 cache storage
  #
  class Storage
    include Singleton

    def initialize
      @s3 = Aws::S3::Client.new
    end

    #
    # Save file to storage
    #
    # @param dir [String]
    # @param key [String]
    # @param value [String]
    #
    def save(dir, key, value)
      set_version dir
      s3_write key, value
    end

    #
    # Returns all items
    #
    # @param dir [String]
    #
    # @return [Array<String>]
    #
    def all(dir)
      list = @s3.list_objects_v2 bucket: ENV["AWS_BUCKET"], prefix: dir
      list.contents.select { |i| i.key.match?(/\.xml$/) }.sort_by(&:key)
        .map do |item|
        content = s3_read item.key
        block_given? ? yield(item.key, content) : content
      end
    end

    def ls(prefix, dirs: true, files: true)
      resp = @s3.list_objects_v2(bucket: ENV["AWS_BUCKET"],
                                 prefix: File.join(prefix, "/"),
                                 delimiter: "/")
      list = []
      list += resp.common_prefixes.map(&:prefix) if dirs
      list += resp.contents.map(&:key) if files
      list
    end

    # Delete item
    # @param keys [String, Array<String>] path to file without extension
    def delete(keys)
      array(keys).map { |f| { key: f } }.each_slice(1000) do |objects|
        @s3.delete_objects bucket: ENV["AWS_BUCKET"], delete: { objects: objects }
      end
    end

    # Check if version of the DB match to the gem grammar hash.
    # @param fdir [String] dir pathe to flavor cache
    # @return [Boolean]
    def check_version?(fdir)
      file_version = File.join fdir, "version"
      s3_read(file_version) == Relaton::DbCache.grammar_hash(fdir)
    rescue Aws::S3::Errors::NoSuchKey
      false
    end

    # Reads file by a key
    #
    # @param key [String]
    # @return [String, NilClass]
    def get(key)
      s3_read key
    end

    #
    # Checks if there is file with xml or txt extension and return filename with
    # the extension.
    #
    # @param file [String]
    # @return [String, NilClass]
    def search_ext(file)
      fs = @s3.list_objects_v2 bucket: ENV["AWS_BUCKET"], prefix: "#{file}."
      fs.contents.first&.key
    end

    private

    def array(content)
      case content
      when Array then content
      when nil then []
      else [content]
      end
    end

    #
    # Read file form AWS S#
    #
    # @param [String] key file name
    #
    # @return [String] content
    #
    def s3_read(key)
      obj = @s3.get_object bucket: ENV["AWS_BUCKET"], key: key
      obj.body.read
    end

    #
    # Write file to AWS S3
    #
    # @param [String] key
    # @param [String] value
    #
    def s3_write(key, value)
      @s3.put_object(bucket: ENV["AWS_BUCKET"], key: key, body: value,
                     content_type: "text/plain; charset=utf-8")
    end

    # Set version of the DB to the gem grammar hash.
    # @param fdir [String] dir pathe to flover cache
    def set_version(fdir)
      file_version = "#{fdir}/version"
      @s3.head_object bucket: ENV["AWS_BUCKET"], key: file_version
    rescue Aws::S3::Errors::NotFound
      s3_write file_version, Relaton::DbCache.grammar_hash(fdir)
    end
  end
end
