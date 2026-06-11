# frozen_string_literal: true

require_relative "api/finder"

module Relaton
  class Api
    class << self
      def handler(event:, context: {})
        router(event) || not_found("Resource doesn't exist.")
      rescue StandardError => e
        $stderr.puts "[ERROR] #{e.class}: #{e.message}"
        $stderr.puts e.backtrace.first(10).join("\n") if e.backtrace
        internal_error("#{e.class}: #{e.message}")
      end

      private

      def router(event)
        case event["path"]
        when /\/api\/v1\/document$/
          fetch(event) if event["httpMethod"] == "GET"
        when /\/api\/v1\/version$/
          version(event["queryStringParameters"]&.fetch("format")) if event["httpMethod"] == "GET"
        end
      end

      def version(format)
        ver = ENV.fetch("API_VERSION", "unknown")
        case format
        when "xml"
          response "<version><release>#{escape(ver)}</release><relaton>#{Relaton::VERSION}</relaton></version>",
                   type: "text/xml"
        when "json"
          response({ release: ver, relaton: Relaton::VERSION }.to_json, type: "application/json")
        else
          response "Release: #{ver}, Relaton version: #{Relaton::VERSION}"
        end
      end

      def fetch(event)
        params = event["queryStringParameters"] || {}
        code = params["code"]&.strip
        return bad_request("Parameter 'code' is required.") if code.nil? || code.empty?

        item = Finder.instance.fetch(normalize(code), params["year"]&.strip, extract_opts(params))
        return not_found("Document not found.") unless item

        response item.to_xml(bibdata: true), type: "text/xml"
      rescue Relaton::RequestError => e
        service_unavailable(e.message)
      rescue ArgumentError => e
        bad_request(e.message)
      end

      def normalize(code)
        code.gsub("\u2014", "-").gsub("\u2013", "-")
            .gsub(/[\p{Z}\u00a0]+/, " ").strip
      end

      def extract_opts(params)
        {}.tap do |opts|
          opts[:all_parts] = params["all_parts"] if params.key?("all_parts")
          opts[:keep_year] = params["keep_year"] if params.key?("keep_year")
        end
      end

      def escape(str)
        str.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
      end

      def bad_request(msg)
        response("Bad request. #{msg}", status: 400)
      end

      def not_found(msg)
        response(msg, status: 404)
      end

      def service_unavailable(msg)
        response(msg, status: 503)
      end

      def internal_error(msg)
        response("Internal error. #{msg}", status: 500)
      end

      def response(body, type: "text/plain", status: 200)
        {
          statusCode: status,
          headers: {
            "Content-Type" => type,
            "Access-Control-Allow-Origin" => "*",
            "Access-Control-Allow-Headers" => "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
            "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
          },
          body: body,
        }
      end
    end
  end
end
