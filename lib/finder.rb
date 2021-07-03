require "singleton"
require "relaton"

Encoding.default_internal = Encoding::UTF_8
Encoding.default_external = Encoding::UTF_8

puts "123 before call finder"
puts ENV["AWS_BUCKET"]

module Relaton
  class Finder
    include Singleton

    def initialize
      puts "123 called finder"
      puts ENV["AWS_BUCKET"]

      Relaton.configure do |config|
        puts "123 called Relaton.configure"
        puts config
        config.use_api = false
        config.api_mode = true
      end

      puts "123 before call Relaton::Db.init_bib_caches"

      @db = Relaton::Db.init_bib_caches global_cache: true

      puts "123 after call Relaton::Db.init_bib_caches"
    end

    def fetch(code, year, opts)
      puts "123 calling fetch"

      ret = @db.fetch code, year, opts

      puts "123 after called   @db.fetch "
      ret
    end
  end
end
