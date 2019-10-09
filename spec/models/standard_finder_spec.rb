require "rails_helper"

RSpec.describe StandardFinder do
  describe ".find_or_fetch_by" do
    context "with existing standard" do
      it "finds and returns the standard" do
        standard = create(:standard, :with_document)

        found_standard = StandardFinder.find_or_fetch_by(
          code: standard.code, year: standard.year,
        )

        expect(found_standard).to eq(standard)
        expect(found_standard.year).to eq(standard.year)
      end
    end

    context "with non existing document" do
      it "fetch and returns the new document" do
        standard_fixture = build(:standard)
        stub_relaton_document(standard_fixture.code, standard_fixture.year)

        standard = StandardFinder.find_or_fetch_by(
          code: standard_fixture.code, year: standard_fixture.year,
        )

        expect(standard.code).to eq(standard_fixture.code)
        expect(standard.year).to eq(standard_fixture.year)
        expect(standard.expires_at.to_date).to eq(5.days.from_now.to_date)
        expect(standard.standard_type).to eq(standard_fixture.standard_type)
        expect(standard.document_in_json["date"]["value"]).to eq("2003-01-01")
        expect(standard.document_in_xml).to include('<bibitem id="ISO19115-200')
        expect(standard.document_number).to eq(standard_fixture.document_number)
      end
    end
  end
end
