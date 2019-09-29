require "rails_helper"

RSpec.describe Finders::KlassFinder do
  describe ".find" do
    it "returns the correct finder class with valid code" do
      code = "ISO 19011"

      finder = Finders::KlassFinder.find(code)
      expect(finder).to eq(Finders::IsoStandard)
    end

    it "returns nil for non supported / invalid code" do
      code = "INVALID 19011"

      expect(Finders::KlassFinder.find(code)).to be_nil
    end
  end
end
