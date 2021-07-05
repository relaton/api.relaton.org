describe Relaton::Api do

  context "GET standard" do
    let(:app) { subject }

    it "returns status 200" do
      VCR.use_cassette "fetch_s3" do
        event = {
          "httpMethod" => "GET",
          "path" => "/api/v1/document",
          "queryStringParameters" => {
            "code" => "ISO 19115-2", "year" => "2019"
          },
        }
        resp = Relaton::Api.handler event: event
        expect(resp[:statusCode]).to eq 200
        expect(resp[:headers]["Content-Type"]).to eq "text/xml"
        expect(resp[:body]).to include "<docnumber>19115</docnumber>"
      end
    end

    context "returns status 404" do
      it "not found" do
        VCR.use_cassette "fetch_s3_not_found" do
          event = {
            "httpMethod" => "GET",
            "path" => "/api/v1/document",
            "queryStringParameters" => { "code" => "ISO 123456" },
          }
          resp = Relaton::Api.handler event: event
          expect(resp[:status]).to eq 404
          expect(resp[:headers]["Content-Type"]).to eq "text/plain"
          expect(resp[:body]).to eq "Document not found."
        end
      end

      # it "resource doesn't exist" do
      #   event = {
      #     "httpMethod" => "GET",
      #     "path" => "/api/v1/fetch",
      #     "queryStringParameters" => { "code" => "ISO 123456" },
      #   }
      #   resp = Relaton::Api.handler event: event
      #   expect(resp[:status]).to eq 404
      #   expect(resp[:headers]["Content-Type"]).to eq "text/plain"
      #   expect(resp[:body]).to eq "Resource doesn't exist."
      # end
    end

    it "returns status 400" do
      event = {
        "httpMethod" => "GET",
        "path" => "/api/v1/document",
        "queryStringParameters" => { "year" => "2019" },
      }
      resp = Relaton::Api.handler event: event
      expect(resp[:status]).to eq 400
      expect(resp[:headers]["Content-Type"]).to eq "text/plain"
      expect(resp[:body]).to eq "Bad request. Parametr 'code' is required."
    end
  end
end
