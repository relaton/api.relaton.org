require "rails_helper"

RSpec.describe "GET /api/standards" do
  context "with valid type and name" do
    it "returns the standard document" do
      standard = create(:standard, :with_document, code: "ISO 19115")
      stub_relaton_document(standard.code, standard.year)

      get_api api_standard_path(code: standard.code, year: standard.year)
      content = JSON.parse(response.body)

      expect(content["updated_at"]).not_to be_nil
      expect(content["code"]).to eq(standard.code)
      expect(content["type"]).to eq(standard.standard_type.upcase)
      expect(content["document"]["xml"]).to include('<bibitem id="ISO19115-200')
    end
  end

  context "with invalid type and name" do
    it "returns not found status" do
      _standard = build(:standard)

      get_api api_standard_path("invalid standard", year: 2019)
      content = JSON.parse(response.body)

      expect(response.status).to eq(422)
      expect(content["error"]).to eq(I18n.t("standards.unprocessable_entity"))
    end
  end
end
