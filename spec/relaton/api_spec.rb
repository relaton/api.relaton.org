describe Relaton::Api do
  before :each do
    allow(ENV).to receive(:fetch).with("API_VERSION").and_return "0.1"
  end

  context ".handler" do
    it "router return response" do
      event = {
        "httpMethod" => "GET",
        "path" => "/api/v1/document",
        "queryStringParameters" => {
          "code" => "ISO 19115-2", "year" => "2019"
        },
      }
      expect(Relaton::Api).to receive(:router).with(event).and_return statusCode: 200
      resp = Relaton::Api.handler event: event
      expect(resp[:statusCode]).to eq 200
    end

    it "call resource_not_exist" do
      event = {
        "httpMethod" => "GET",
        "path" => "/api/v1/document",
        "queryStringParameters" => {
          "code" => "ISO 19115-2", "year" => "2019"
        },
      }
      expect(Relaton::Api).to receive(:router).with(event).and_return nil
      expect(Relaton::Api).to receive(:resource_not_exist).and_return statusCode: 404
      resp = Relaton::Api.handler event: event
      expect(resp[:statusCode]).to eq 404
    end

    it "handle error" do
      expect do
        expect(Relaton::Api).to receive(:router).and_raise StandardError
        Relaton::Api.handler event: nil
      end.to output(/Execution error!/).to_stdout
    end
  end

  context ".router" do
    it "fetch document" do
      event = { "path" => "/api/v1/document", "httpMethod" => "GET" }
      expect(Relaton::Api).to receive(:fetch).with(event).and_return :resp
      expect(Relaton::Api.send(:router, event)).to eq :resp
    end

    it "return version" do
      event = {
        "path" => "/api/v1/version",
        "httpMethod" => "GET",
        "queryStringParameters" => { "format" => "json" },
      }
      expect(Relaton::Api).to receive(:version).with("json").and_return :ver
      expect(Relaton::Api.send(:router, event)).to eq :ver
    end

    it "return nil when path is unknown" do
      event = { "path" => "/api/v1/unknown", "httpMethod" => "GET" }
      expect(Relaton::Api.send(:router, event)).to be_nil
    end

    it "return nil when method is unknown" do
      event = { "path" => "/api/v1/document", "httpMethod" => "POST" }
      expect(Relaton::Api.send(:router, event)).to be_nil
    end
  end

  context ".version" do
    it "XML format" do
      resp = Relaton::Api.send(:version, "xml")
      headers = resp[:headers]
      expect(resp[:statusCode]).to eq 200
      expect(headers["Access-Control-Allow-Headers"]).to eq(
        "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
      )
      expect(headers["Access-Control-Allow-Methods"]).to eq "GET, POST, OPTIONS"
      expect(headers["Access-Control-Allow-Origin"]).to eq "*"
      expect(headers["Content-Type"]).to eq "text/xml"
      expect(resp[:body]).to match(
        /<version><release>\d+\.\d+<\/release><relaton>\d+\.\d+\.\d+<\/relaton><\/version>/,
      )
    end

    it "JSON format" do
      resp = Relaton::Api.send(:version, "json")
      expect(resp[:headers]["Content-Type"]).to eq "application/json"
      expect(resp[:body]).to match(/{"release":"\d+\.\d+","relaton":"\d+\.\d+.\d+"}/)
    end

    it "default text format" do
      resp = Relaton::Api.send(:version, nil)
      expect(resp[:headers]["Content-Type"]).to eq "text/plain"
      expect(resp[:body]).to match(/Release:\s\d+\.\d+,\sRelaton\sversion:\s\d+\.\d+\.\d+/)
    end
  end

  context ".fetch" do
    context "bad request" do
      it "queryStringParameters is missed" do
        resp = Relaton::Api.send(:fetch, "path" => "/api/v1/document")
        expect(resp[:statusCode]).to eq 400
        expect(resp[:body]).to eq(
          "Bad request. Parameters are missed or incorrect. See the documentation " \
          "https://github.com/relaton/api.relaton.org#fetch-bibdata-of-a-document",
        )
      end

      it "code is missed" do
        resp = Relaton::Api.send(:fetch, "queryStringParameters" => {})
        expect(resp[:statusCode]).to eq 400
        expect(resp[:body]).to eq("Bad request. Parameter 'code' is required.")
      end
    end

    context "call finder" do
      let(:event) do
        { "queryStringParameters" => { "code" => "ISO 19115-2", "year" => "2019" } }
      end

      let(:finder) { double "finder" }

      before :each do
        expect(Relaton::Finder).to receive(:instance).and_return finder
      end

      it "not found" do
        expect(finder).to receive(:fetch).with("ISO 19115-2", "2019", {}).and_return nil
        resp = described_class.send(:fetch, event)
        expect(resp[:statusCode]).to eq 404
        expect(resp[:body]).to eq "Document not found."
      end

      it "found" do
        item = double "item"
        expect(item).to receive(:to_xml).with(bibdata: true).and_return "<xml/>"
        expect(finder).to receive(:fetch).with("ISO 19115-2", "2019", {}).and_return item
        resp = described_class.send(:fetch, event)
        expect(resp[:statusCode]).to eq 200
        expect(resp[:headers]["Content-Type"]).to eq "text/xml"
        expect(resp[:body]).to eq "<xml/>"
      end

      it "hadle Aws::Xml::Parser::ParsingError" do
        expect(finder).to receive(:fetch).and_raise Aws::Xml::Parser::ParsingError.new("error", 1, 1)
        resp = described_class.send(:fetch, event)
        expect(resp[:statusCode]).to eq 400
        expect(resp[:body]).to eq(
          "Bad request. Parameter 'code' contains invalid symbols. See this guide " \
          "https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-keys.html",
        )
      end

      it "handle RelatonBib::RequestError" do
        expect(finder).to receive(:fetch).and_raise RelatonBib::RequestError, "error"
        resp = described_class.send(:fetch, event)
        expect(resp[:statusCode]).to eq 503
        expect(resp[:body]).to eq "error"
      end
    end
  end

  it ".resource_not_exist" do
    resp = described_class.send(:resource_not_exist)
    expect(resp[:statusCode]).to eq 404
    expect(resp[:body]).to eq "Resource doesn't exist."
  end
end
