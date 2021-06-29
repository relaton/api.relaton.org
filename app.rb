require "rack"
require "./finder"

module Relaton
  class Api
    def call(env)
      req = Rack::Request.new env
      if req.get? && req.path == "/api/v1/fetch"
        return bad_request "Parametr 'code' is required." unless req.params["code"]

        fetch req
      else not_found "Resource doesn't exist."
      end
    end

    private

    def fetch(req)
      item = Relaton::Finder.instance.fetch(*params(req))
      return not_found "Document not found" unless item

      [200, { "Content-Type" => "text/xml" }, [item.to_xml(bibdata: true)]]
    end

    def params(req)
      opts = req.params.each_with_object({}) do |(k, v), o|
        %w[all_parts keep_year].include?(k) && o[k.to_sym] = v
      end
      [req.params["code"], req.params["year"], opts]
    end

    def bad_request(msg)
      [400, { "Content-Type" => "text/plain" }, ["Bad request. #{msg}"]]
    end

    def not_found(msg)
      [404, { "Content-Type" => "text/plain" }, [msg]]
    end
  end
end
