# frozen_string_literal: true

require_relative "finder"

module Relaton
  class Api
    class << self
      #
      # AWS Lambda handler
      #
      # @param [Hash] event
      # @option event [String] :path
      # @option event [Hash] :queryStringParameters
      #
      # @param [Hash] context
      #
      # @return [Hash] AWS Lambda response
      #
      def handler(event:, context: {}) # rubocop:disable Lint/UnusedMethodArgument
        router(event) || resource_not_exist
      rescue StandardError => e
        puts "Execution error!"
        puts e.message
        puts e.backtrace
      end

      private

      #
      # Route request
      #
      # @param [Hash] event
      # @option event [String] :path
      # @option event [Hash] :queryStringParameters
      #
      # @return [Hash] AWS Lambda response
      #
      def router(event) # rubocop:disable Metrics/MethodLength
        case event["path"]
        when /\/api\/v1\/document$/
          case event["httpMethod"]
          when "GET" then fetch event
          end
        when /\/api\/v1\/version$/
          case event["httpMethod"]
          when "GET" then version event["queryStringParameters"]&.fetch("format")
          end
        end
      end

      #
      # Formatted version response
      #
      # @param [String, nil] format
      #
      # @return [Hash] <description>
      #
      def version(format) # rubocop:disable Metrics/MethodLength
        version = ENV.fetch "API_VERSION"
        case format
        when "xml"
          xml = "<version><release>#{version}</release><relaton>#{Relaton::VERSION}</relaton></version>"
          response xml, type: "text/xml"
        when "json"
          json = { release: version, relaton: Relaton::VERSION }.to_json
          response json, type: "application/json"
        else
          response "Release: #{version}, Relaton version: #{Relaton::VERSION}"
        end
      end

      #
      # Look up a document
      #
      # @param [Hash] event
      # @option event [Hash] :queryStringParameters
      #
      # @return [Hash] AWS Lambda response
      #
      def fetch(event) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        if event["queryStringParameters"].nil?
          return bad_request "Parameters are missed or incorrect. "\
                             "See the documentation https://github.com/relaton"\
                             "/api.relaton.org#fetch-bibdata-of-a-document"
        elsif event["queryStringParameters"]["code"].nil?
          return bad_request "Parameter 'code' is required."
        end

        item = Relaton::Finder.instance.fetch(*params(event))
        return not_found "Document not found." unless item

        xml = item.to_xml bibdata: true
        response xml, type: "text/xml"
      rescue Aws::Xml::Parser::ParsingError
        bad_request "Parameter 'code' contains invalid symbols. "\
                    "See this guide https://docs.aws.amazon.com/AmazonS3/"\
                    "latest/userguide/object-keys.html"
      rescue RelatonBib::RequestError => e
        service_unavailable e.message
      end

      #
      # Parameters for document fetching
      #
      # @param [Hash] event
      # @option event [Hash] :queryStringParameters
      #
      # @return [Array<String, Hash>]
      #
      def params(event)
        allowed_params = %w[all_parts keep_year]
        opts = event["queryStringParameters"].each_with_object({}) do |(k, v), o|
          allowed_params.include?(k) && o[k.to_sym] = v
        end

        [
          event["queryStringParameters"]["code"],
          event["queryStringParameters"]["year"],
          opts,
        ]
      end

      #
      # Respond resourse not exist
      #
      # @return [Hash] AWS Lambda response
      #
      def resource_not_exist
        not_found "Resource doesn't exist."
      end

      #
      # Bad request response
      #
      # @param [String] msg
      #
      # @return [Hash] AWS Lambda response
      #
      def bad_request(msg)
        response "Bad request. #{msg}", status: 400
      end

      #
      # Not found response
      #
      # @param [String] msg
      #
      # @return [Hash] AWS Lambda response
      #
      def not_found(msg)
        response msg, status: 404
      end

      #
      # Service unavailable respoonse
      #
      # @param [String] msg message
      #
      # @return [Hash] AWS Lambda response
      #
      def service_unavailable(msg)
        response msg, status: 503
      end

      #
      # AWS Lambda response
      #
      # @param [String] body
      # @param [String] type
      # @param [Integer] status
      #
      # @return [Hash] AWS Lambda response
      #
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
