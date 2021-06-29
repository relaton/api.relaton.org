describe Relaton::Api do
  include Rack::Test::Methods

  context "GET standatd" do
    let(:app) { subject }

    it "returns status 200" do
      VCR.use_cassette "fetch_s3" do
        ENV["AWS_BUCKET"] = "bucket"
        ENV["AWS_REGION"] = "us-west"
        ENV["AWS_ACCESS_KEY_ID"] = "AWS_ACCESS_KEY_ID"
        ENV["AWS_SECRET_ACCESS_KEY"] = "AWS_SECRET_ACCESS_KEY"
        expect(ENV).to receive(:[]).and_call_original.at_least :once
        get "/api/v1/fetch?code=ISO 19115-2&year=2019"
        expect(last_response.status).to eq 200
      end
    end
  end
end
