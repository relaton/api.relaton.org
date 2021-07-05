require_relative "finder"

module Relaton
  class Api
    class << self
      def handler(event:, context: {})
        if event["httpMethod"] == "GET" && event["path"].match?(/\/api\/v1\/document$/)
          unless event["queryStringParameters"]["code"]
            return bad_request "Parametr 'code' is required."
          end

          fetch event
        else not_found "Resource doesn't exist."
        end
      rescue => e
        puts "Execution error!"
        puts e.message
        puts e.backtrace
      end

      private

      def fetch(env)
        item = Relaton::Finder.instance.fetch(*params(env))
        return not_found "Document not found." unless item

        xml = item.to_xml bibdata: true

        {
          statusCode: 200,
          headers: { "Content-Type" => "text/xml" },
          body: xml,
        }
      end

      def params(env)
        allowed_params = %w[all_parts keep_year]
        opts = env["queryStringParameters"].each_with_object({}) do |(k, v), o|
          allowed_params.include?(k) && o[k.to_sym] = v
        end

        [
          env["queryStringParameters"]["code"],
          env["queryStringParameters"]["year"],
          opts,
        ]
      end

      def bad_request(msg)
        {
          status: 400,
          headers: { "Content-Type" => "text/plain" },
          body: "Bad request. #{msg}",
        }
      end

      def not_found(msg)
        { status: 404, headers: { "Content-Type" => "text/plain" }, body: msg }
      end
    end
  end
end
