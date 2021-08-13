describe RelatonCalconnect::HitCollection do
  it "fetch document from GH" do
    VCR.use_cassette "CC 18011:2018" do
      hc = RelatonCalconnect::HitCollection.new "CC 18011:2018"
      expect(hc.first).to be_instance_of RelatonCalconnect::Hit
    end
  end
end
