require "rails_helper"

RSpec.describe Finders::IsoStandard do
  describe ".find" do
    context "with existing document" do
      it "finds and returns the document" do
        year = 2003
        code = "ISO 19115"

        stub_iso_document_fetch(code, year.to_s)
        document = Finders::IsoStandard.find(code, year)

        expect(document.id).to eq("ISO19115-2003")
        expect(document.class).to eq(RelatonIsoBib::IsoBibliographicItem)
      end
    end

    context "with not existing document" do
      it "return nils" do
        year = 2019
        code = "ISO 19115"

        allow(RelatonIso::IsoBibliography).to receive(:get).and_return(nil)
        document = Finders::IsoStandard.find(code, year)

        expect(document).to be_nil
      end
    end
  end

  def stub_iso_document_fetch(code, year)
    filename = (code + ":" + year + ".xml").gsub(" ", "-")

    allow(RelatonIso::IsoBibliography).to receive(:get).
      with(code, year, {}).and_return(bib_fixture_file(filename))
  end

  def bib_fixture_file(name)
    RelatonIsoBib::XMLParser.
      from_xml(File.read(Rails.root.join("spec", "fixtures", name)))
  end
end
