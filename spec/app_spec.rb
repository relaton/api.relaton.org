describe Relaton::Api do
  # context "GET standard" do
  #   before :each do
  #     allow(Relaton::Storage.instance).to receive(:get_version).and_return(nil)
  #   end

  #   context "Returns version" do
  #     before :each do
  #       expect(ENV).to receive(:fetch).with("API_VERSION").and_return "0.1"
  #     end

  #     it "plain text" do
  #       event = {
  #         "httpMethod" => "GET",
  #         "path" => "/api/v1/version",
  #       }
  #       resp = Relaton::Api.handler event: event
  #       expect(resp[:statusCode]).to eq 200
  #       expect(resp[:headers]["Content-Type"]).to eq "text/plain"
  #       expect(resp[:body]).to include "Release: 0.1, Relaton version:"
  #     end

  #     it "xml" do
  #       event = {
  #         "httpMethod" => "GET",
  #         "path" => "/api/v1/version",
  #         "queryStringParameters" => { "format" => "xml" },
  #       }
  #       resp = Relaton::Api.handler event: event
  #       expect(resp[:statusCode]).to eq 200
  #       expect(resp[:headers]["Content-Type"]).to eq "text/xml"
  #       expect(resp[:body]).to include "<version><release>0.1</release><relaton>"
  #     end

  #     it "json" do
  #       event = {
  #         "httpMethod" => "GET",
  #         "path" => "/api/v1/version",
  #         "queryStringParameters" => { "format" => "json" },
  #       }
  #       resp = Relaton::Api.handler event: event
  #       expect(resp[:statusCode]).to eq 200
  #       expect(resp[:headers]["Content-Type"]).to eq "application/json"
  #       expect(resp[:body]).to include "{\"release\":\"0.1\",\"relaton\":"
  #     end
  #   end

  #   context "returns status 404" do
  #     it "not found" do
  #       VCR.use_cassette "fetch_s3_not_found" do
  #         event = {
  #           "httpMethod" => "GET",
  #           "path" => "/api/v1/document",
  #           "queryStringParameters" => { "code" => "ISO 123456" },
  #         }
  #         resp = Relaton::Api.handler event: event
  #         expect(resp[:statusCode]).to eq 404
  #         expect(resp[:headers]["Content-Type"]).to eq "text/plain"
  #         expect(resp[:body]).to eq "Document not found."
  #       end
  #     end

  #     it "resource doesn't exist" do
  #       event = {
  #         "httpMethod" => "GET",
  #         "path" => "/api/v1/fetch",
  #         "queryStringParameters" => { "code" => "ISO 123456" },
  #       }
  #       resp = Relaton::Api.handler event: event
  #       expect(resp[:statusCode]).to eq 404
  #       expect(resp[:headers]["Content-Type"]).to eq "text/plain"
  #       expect(resp[:body]).to eq "Resource doesn't exist."
  #     end
  #   end

  #   context "returns status 400" do
  #     it "missed code parameter" do
  #       event = {
  #         "httpMethod" => "GET",
  #         "path" => "/api/v1/document",
  #         "queryStringParameters" => { "year" => "2019" },
  #       }
  #       resp = Relaton::Api.handler event: event
  #       expect(resp[:statusCode]).to eq 400
  #       expect(resp[:headers]["Content-Type"]).to eq "text/plain"
  #       expect(resp[:body]).to eq "Bad request. Parameter 'code' is required."
  #     end

  #     it "missed search prarameters" do
  #       event = {
  #         "httpMethod" => "GET",
  #         "path" => "/api/v1/document",
  #       }
  #       resp = Relaton::Api.handler event: event
  #       expect(resp[:statusCode]).to eq 400
  #       expect(resp[:headers]["Content-Type"]).to eq "text/plain"
  #       expect(resp[:body]).to include "Bad request. Parameters are missed or incorrect."
  #     end

  #     it "incorrect code" do
  #       event = {
  #         "httpMethod" => "GET",
  #         "path" => "/api/v1/document",
  #         "queryStringParameters" => { "code" => "ISO\u0010241-1" },
  #       }
  #       VCR.use_cassette "incorrect_code" do
  #         resp = Relaton::Api.handler event: event
  #         expect(resp[:statusCode]).to eq 400
  #         expect(resp[:headers]["Content-Type"]).to eq "text/plain"
  #         expect(resp[:body]).to include "Bad request. Parameter 'code' contains invalid symbols."
  #       end
  #     end
  #   end

  #   context "return status 503" do
  #     it "service unavailble" do
  #       event = {
  #         "httpMethod" => "GET",
  #         "path" => "/api/v1/document",
  #         "queryStringParameters" => { "code" => "ISO\u0010241-1" },
  #       }
  #       Singleton.__init__ Relaton::Finder
  #       db = double "db instance"
  #       expect(db).to receive(:fetch).and_raise RelatonBib::RequestError
  #       expect(Relaton::Db).to receive(:init_bib_caches).and_return db
  #       Relaton::Api.handler event: event
  #     end
  #   end
  # end

  # it "log error" do
  #   event = {
  #     "httpMethod" => "GET",
  #     "path" => "/api/v1/document",
  #     "queryStringParameters" => { "code" => "ISO 123456" },
  #   }
  #   expect(subject.class).to receive(:fetch).and_raise SocketError
  #   expect { Relaton::Api.handler event: event }.to output(/Execution error!/).to_stdout
  # end
end
