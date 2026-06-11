describe Relaton::Api do
  before :each do
    allow(ENV).to receive(:fetch).with("API_VERSION", any_args).and_return "0.1"
  end

  context ".handler" do
    it "returns router response" do
      event = {
        "httpMethod" => "GET",
        "path" => "/api/v1/document",
        "queryStringParameters" => { "code" => "ISO 19115-2", "year" => "2019" },
      }
      expect(Relaton::Api).to receive(:router).with(event).and_return(statusCode: 200)
      resp = Relaton::Api.handler(event: event)
      expect(resp[:statusCode]).to eq 200
    end

    it "returns 404 when router returns nil" do
      event = {
        "httpMethod" => "GET",
        "path" => "/api/v1/document",
        "queryStringParameters" => { "code" => "ISO 19115-2", "year" => "2019" },
      }
      expect(Relaton::Api).to receive(:router).with(event).and_return nil
      resp = Relaton::Api.handler(event: event)
      expect(resp[:statusCode]).to eq 404
      expect(resp[:body]).to eq "Resource doesn't exist."
    end

    it "returns 500 on unhandled error" do
      expect(Relaton::Api).to receive(:router).and_raise StandardError, "boom"
      resp = Relaton::Api.handler(event: nil)
      expect(resp[:statusCode]).to eq 500
      expect(resp[:body]).to include "Internal error. StandardError: boom"
    end
  end

  context ".router" do
    it "routes to fetch" do
      event = { "path" => "/api/v1/document", "httpMethod" => "GET" }
      expect(Relaton::Api).to receive(:fetch).with(event).and_return :resp
      expect(Relaton::Api.send(:router, event)).to eq :resp
    end

    it "routes to version" do
      event = {
        "path" => "/api/v1/version",
        "httpMethod" => "GET",
        "queryStringParameters" => { "format" => "json" },
      }
      expect(Relaton::Api).to receive(:version).with("json").and_return :ver
      expect(Relaton::Api.send(:router, event)).to eq :ver
    end

    it "returns nil for unknown path" do
      event = { "path" => "/api/v1/unknown", "httpMethod" => "GET" }
      expect(Relaton::Api.send(:router, event)).to be_nil
    end

    it "returns nil for unsupported method" do
      event = { "path" => "/api/v1/document", "httpMethod" => "POST" }
      expect(Relaton::Api.send(:router, event)).to be_nil
    end
  end

  context ".version" do
    it "returns XML" do
      resp = Relaton::Api.send(:version, "xml")
      expect(resp[:statusCode]).to eq 200
      expect(resp[:headers]["Content-Type"]).to eq "text/xml"
      expect(resp[:body]).to match(%r{<version><release>0\.1</release><relaton>\d+\.\d+\.\d+</relaton></version>})
    end

    it "returns JSON" do
      resp = Relaton::Api.send(:version, "json")
      expect(resp[:headers]["Content-Type"]).to eq "application/json"
      expect(resp[:body]).to match(/{"release":"0\.1","relaton":"\d+\.\d+\.\d+"}/)
    end

    it "returns plain text" do
      resp = Relaton::Api.send(:version, nil)
      expect(resp[:headers]["Content-Type"]).to eq "text/plain"
      expect(resp[:body]).to match(/Release:\s0\.1,\sRelaton\sversion:\s\d+\.\d+\.\d+/)
    end
  end

  context ".fetch" do
    let(:event) { { "queryStringParameters" => { "code" => "ISO 19115-2", "year" => "2019" } } }
    let(:finder) { instance_double(Relaton::Api::Finder) }

    before :each do
      allow(Relaton::Api::Finder).to receive(:instance).and_return finder
    end

    context "bad request" do
      it "rejects missing query string" do
        resp = Relaton::Api.send(:fetch, "path" => "/api/v1/document")
        expect(resp[:statusCode]).to eq 400
        expect(resp[:body]).to eq "Bad request. Parameter 'code' is required."
      end

      it "rejects missing code" do
        resp = Relaton::Api.send(:fetch, "queryStringParameters" => {})
        expect(resp[:statusCode]).to eq 400
        expect(resp[:body]).to eq "Bad request. Parameter 'code' is required."
      end

      it "rejects empty code" do
        resp = Relaton::Api.send(:fetch, "queryStringParameters" => { "code" => "  " })
        expect(resp[:statusCode]).to eq 400
        expect(resp[:body]).to eq "Bad request. Parameter 'code' is required."
      end
    end

    context "finder integration" do
      it "returns 404 when document not found" do
        expect(finder).to receive(:fetch).with("ISO 19115-2", "2019", {}).and_return nil
        resp = described_class.send(:fetch, event)
        expect(resp[:statusCode]).to eq 404
        expect(resp[:body]).to eq "Document not found."
      end

      it "returns XML document when found" do
        item = double("item")
        expect(item).to receive(:to_xml).with(bibdata: true).and_return "<xml/>"
        expect(finder).to receive(:fetch).with("ISO 19115-2", "2019", {}).and_return item
        resp = described_class.send(:fetch, event)
        expect(resp[:statusCode]).to eq 200
        expect(resp[:headers]["Content-Type"]).to eq "text/xml"
        expect(resp[:body]).to eq "<xml/>"
      end

      it "returns 503 on RequestError" do
        expect(finder).to receive(:fetch).and_raise Relaton::RequestError, "upstream down"
        resp = described_class.send(:fetch, event)
        expect(resp[:statusCode]).to eq 503
        expect(resp[:body]).to eq "upstream down"
      end

      it "returns 400 on ArgumentError" do
        expect(finder).to receive(:fetch).and_raise ArgumentError, "bad args"
        resp = described_class.send(:fetch, event)
        expect(resp[:statusCode]).to eq 400
        expect(resp[:body]).to eq "Bad request. bad args"
      end
    end

    context "input normalization" do
      it "normalizes whitespace in code" do
        event = { "queryStringParameters" => { "code" => "  ISO\u00A019115-2  " } }
        item = double("item")
        expect(item).to receive(:to_xml).with(bibdata: true).and_return "<xml/>"
        expect(finder).to receive(:fetch).with("ISO 19115-2", nil, {}).and_return item
        resp = described_class.send(:fetch, event)
        expect(resp[:statusCode]).to eq 200
      end
    end
  end

  context ".normalize" do
    it "collapses whitespace" do
      expect(Relaton::Api.send(:normalize, "ISO\u00A0\u00A09000")).to eq "ISO 9000"
    end

    it "strips leading/trailing space" do
      expect(Relaton::Api.send(:normalize, "  ISO 9000  ")).to eq "ISO 9000"
    end

    it "leaves clean input unchanged" do
      expect(Relaton::Api.send(:normalize, "ISO 9000:2015")).to eq "ISO 9000:2015"
    end
  end

  context ".extract_opts" do
    it "extracts all_parts" do
      params = { "all_parts" => "true", "code" => "ISO 9000" }
      opts = Relaton::Api.send(:extract_opts, params)
      expect(opts).to eq(all_parts: "true")
    end

    it "extracts keep_year" do
      params = { "keep_year" => "false", "code" => "ISO 9000" }
      opts = Relaton::Api.send(:extract_opts, params)
      expect(opts).to eq(keep_year: "false")
    end

    it "returns empty hash for no opts" do
      opts = Relaton::Api.send(:extract_opts, "code" => "ISO 9000")
      expect(opts).to eq({})
    end
  end

  context "response helpers" do
    it "bad_request" do
      resp = Relaton::Api.send(:bad_request, "nope")
      expect(resp[:statusCode]).to eq 400
      expect(resp[:body]).to eq "Bad request. nope"
    end

    it "not_found" do
      resp = Relaton::Api.send(:not_found, "gone")
      expect(resp[:statusCode]).to eq 404
      expect(resp[:body]).to eq "gone"
    end

    it "service_unavailable" do
      resp = Relaton::Api.send(:service_unavailable, "retry later")
      expect(resp[:statusCode]).to eq 503
      expect(resp[:body]).to eq "retry later"
    end

    it "internal_error" do
      resp = Relaton::Api.send(:internal_error, "boom")
      expect(resp[:statusCode]).to eq 500
      expect(resp[:body]).to eq "Internal error. boom"
    end

    it "includes CORS headers" do
      resp = Relaton::Api.send(:response, "ok")
      expect(resp[:headers]["Access-Control-Allow-Origin"]).to eq "*"
      expect(resp[:headers]["Access-Control-Allow-Headers"]).to include "Content-Type"
      expect(resp[:headers]["Access-Control-Allow-Methods"]).to eq "GET, POST, OPTIONS"
    end
  end
end
