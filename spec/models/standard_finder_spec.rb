require "rails_helper"

RSpec.describe StandardFinder do
  describe ".find_by" do
    context "with valid standard details" do
      it "finds and returns the standard" do
        year = 2003
        code = "ISO 19115"
        stub_relaton_document(code, year)

        standard = StandardFinder.find_by(code: code, year: year)
        hash_document = standard.document_in_hash

        expect(standard.code).to eq(code)
        expect(standard.year).to eq(year)
        expect(standard.standard_type).to eq("iso")
        expect(standard.document_number).to eq("19115")
        expect(hash_document["date"]["value"]).to eq("2003-01-01")
        expect(hash_document["docid"]["id"]).to eq("ISO 19115:2003")
        expect(standard.document_in_xml).to include('<bibitem id="ISO19115-200')
      end
    end

    context "with invalid standard details" do
      it "does not returns anything but nil" do
        year = 2019
        code = "ISO 19115"

        stub_relaton_invalid_document(code, year)
        standard = StandardFinder.find_by(code: code, year: year)

        expect(standard).to be_nil
      end
    end
  end
end
