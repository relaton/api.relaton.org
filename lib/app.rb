# frozen_string_literal: true

require_relative "finder"

module Relaton
  class Api
    VERSION = "0.0.7"

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
          when "GET"
            unless event["queryStringParameters"]["code"]
              return bad_request "Parametr 'code' is required."
            end

            fetch event
          end
        when /\/api\/v1\/version$/
          case event["httpMethod"]
          when "GET"
            response "Version: #{VERSION}, Relaton version: #{Relaton::VERSION}"
          end
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
      def fetch(event)
        item = Relaton::Finder.instance.fetch(*params(event))
        return not_found "Document not found." unless item

        xml = item.to_xml bibdata: true
        response xml, type: "text/xml"
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
            "Access-Control-Allow-Origin" => "http://dev.local:4000",
            "Access-Control-Allow-Headers" => "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
            "Access-Control-Allow-Methods" => "GET, POST, OPTIONS",
          },
          body: body,
        }
      end
    end
  end
end
