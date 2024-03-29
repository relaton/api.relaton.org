require "aws-sdk-s3"
require "aws-partitions"

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
    # @param key [String]
    # @param value [String]
    #
    def save(key, value)
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
      list = @s3.list_objects_v2 bucket: ENV.fetch("AWS_BUCKET"), prefix: dir
      list.contents.select { |i| i.key.match?(/\.xml$/) }.sort_by(&:key)
        .map do |item|
        content = s3_read item.key
        block_given? ? yield(item.key, content) : content
      end
    end

    #
    # List all files with prefix in the bucket
    #
    # @param [String] prefix file name prefix
    #
    # @return [Array<String>] list of files
    #
    def ls(prefix)
      list_objects(prefix).contents.map(&:key)
    end

    #
    # List all directories with prefix in the bucket
    #
    # @param [String] prefix directory name prefix
    #
    # @return [Array<String>] list of directories
    #
    def ls_dir(prefix)
      list_objects(prefix).common_prefixes.map(&:prefix)
    end

    #
    # Request list of objects from AWS S3
    #
    # @param [String] prefix prefix
    #
    # @return [Seahorse::Client::Response] S3 response
    #
    def list_objects(prefix)
      @s3.list_objects_v2(bucket: ENV.fetch("AWS_BUCKET"),
                          prefix: File.join(prefix, "/"),
                          delimiter: "/")
    end

    # Delete item
    # @param keys [String, Array<String>] path to file without extension
    def delete(keys)
      RelatonBib.array(keys).map { |f| { key: f } }.each_slice(1000) do |objects|
        @s3.delete_objects bucket: ENV.fetch("AWS_BUCKET"), delete: { objects: objects }
      end
    end

    # Read version file with saved hash.
    # @param fdir [String] dir pathe to flavor cache
    # @return [String, nil]
    def get_version(fdir)
      file_version = File.join fdir, "version"
      s3_read(file_version)
    rescue Aws::S3::Errors::NoSuchKey
      nil
    end

    # Reads file by a key
    #
    # @param key [String]
    # @return [String, nil]
    def get(key)
      s3_read key
    end

    #
    # Checks if there is file with xml or txt extension and return filename with
    # the extension.
    #
    # @param file [String]
    # @return [String, nil]
    def search_ext(file)
      fs = @s3.list_objects_v2 bucket: ENV.fetch("AWS_BUCKET"), prefix: "#{file}."
      fs.contents.first&.key
    end

    # Save version of the DB to the gem grammar hash.
    # @param fdir [String] dir pathe to flover cache
    # @param hash [String] hash string
    def save_version(fdir, hash)
      file_version = "#{fdir}/version"
      @s3.head_object bucket: ENV.fetch("AWS_BUCKET"), key: file_version
    rescue Aws::S3::Errors::NotFound
      s3_write file_version, hash
    end

    private

    #
    # Read file form AWS S#
    #
    # @param [String] key file name
    #
    # @return [String] content
    #
    def s3_read(key)
      obj = @s3.get_object bucket: ENV.fetch("AWS_BUCKET"), key: key
      obj.body.read
    end

    #
    # Write file to AWS S3
    #
    # @param [String] key
    # @param [String] value
    #
    def s3_write(key, value)
      @s3.put_object(bucket: ENV.fetch("AWS_BUCKET"), key: key, body: value,
                     content_type: "text/plain; charset=utf-8")
    end
  end
end
