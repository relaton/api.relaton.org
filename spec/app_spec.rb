describe Relaton::Api do
  include Rack::Test::Methods

  context "GET standatd" do
    let(:app) { subject }

    it "returns status 200" do
      get "/api/v1/standard?code=ISO 19115-2&year=2019"
      expect(last_response.status).to eq 200
    end
  end
end
