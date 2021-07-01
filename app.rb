require "./finder"

module Relaton
  class Api
    class << self
      def handler(event:, context: {})
        if event["httpMethod"] == "GET" && event["path"] == "/api/v1/document"
          unless event["queryStringParameters"]["code"]
            return bad_request "Parametr 'code' is required."
          end

          fetch event
        else not_found "Resource doesn't exist."
        end
      end

      private

      # def headers
      #   # cors_origin = ENV["DEFAULT_ORIGIN"]
      #   # input_origin = event.fetch("headers", {}).fetch("origin", "")

      #   # if /#{ENV["CORS_ORIGIN_REGEX"]}/.match? input_origin
      #   #   cors_origin = input_origin
      #   # end

      #   {
      #     "Access-Control-Allow-Origin" => "*",
      #     "Access-Control-Allow-Headers" => "Content-Type",
      #     "Access-Control-Allow-Methods" => "GET",
      #   }
      # end

      def fetch(env)
        item = Relaton::Finder.instance.fetch(*params(env))
        return not_found "Document not found." unless item

        {
          status: 200,
          headers: { "Content-Type" => "text/xml" },
          body: item.to_xml(bibdata: true),
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
