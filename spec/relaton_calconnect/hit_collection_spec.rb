describe RelatonCalconnect::HitCollection do
  it "fetch document from GH" do
    VCR.use_cassette "cc_18011_2018" do
      hc = RelatonCalconnect::HitCollection.new "CC 18011:2018"
      expect(hc.first).to be_instance_of RelatonCalconnect::Hit
      expect(hc.first.fetch).to be_instance_of RelatonCalconnect::CcBibliographicItem
    end
  end
end
