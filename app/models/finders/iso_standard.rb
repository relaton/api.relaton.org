require "relaton_iso"

module Finders
  class IsoStandard
    def initialize(code:, year: nil, options: {})
      @code = code
      @year = year
      @options = options
    end

    def find
      find_document
    end

    def self.find(code, year, options = {})
      new(code: code, year: year, options: options).find
    end

    private

    attr_reader :code, :year, :options

    def find_document
      RelatonIso::IsoBibliography.get(code, year.to_s, options)
    end
  end
end
