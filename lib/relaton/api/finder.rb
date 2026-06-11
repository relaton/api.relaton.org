# frozen_string_literal: true

require "singleton"
require "relaton"

Relaton::Registry.instance

require_relative "../../override/relaton/db"

module Relaton
  class Api
    class Finder
      include Singleton

      PUBID_MAP = {
        relaton_iso: "pubid/iso",
        relaton_iec: "pubid/iec",
        relaton_ieee: "pubid/ieee",
        relaton_itu: "pubid/itu",
        relaton_nist: "pubid/nist",
        relaton_iho: "pubid/iho",
        relaton_bsi: "pubid/bsi",
        relaton_cen: "pubid/cen",
        relaton_jis: "pubid/jis",
        relaton_ccsds: "pubid/ccsds",
        relaton_etsi: "pubid/etsi",
        relaton_plateau: "pubid/plateau",
      }.freeze

      def initialize
        Relaton.configure { |config| config.use_api = false }
        @registry = Relaton::Registry.instance
        @db = Relaton::Db.init_bib_caches global_cache: true
      end

      def fetch(code, year = nil, opts = {})
        year = nil if year && embedded_year?(code)
        @db.fetch(code, year, opts)
      end

      private

      def embedded_year?(code)
        stdclass = @registry.class_by_ref(code)
        return false unless stdclass

        path = PUBID_MAP[stdclass]
        return false unless path

        require path
        mod = pubid_module(stdclass)
        return false unless mod

        parsed = mod::Identifier.parse(code)
        !parsed.year.nil?
      rescue StandardError
        false
      end

      def pubid_module(stdclass)
        name = stdclass.to_s.sub("relaton_", "").capitalize
        Pubid.const_get(name, false)
      rescue NameError
        nil
      end
    end
  end
end
