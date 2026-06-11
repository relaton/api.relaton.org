describe Relaton::Api::Finder do
  let(:db) { instance_double(Relaton::Db) }

  before do
    Singleton.__init__(described_class)
    config = double("config")
    allow(config).to receive(:use_api=)
    allow(Relaton).to receive(:configure).and_yield(config)
    allow(Relaton::Db).to receive(:init_bib_caches).with(global_cache: true).and_return db
  end

  it "initializes" do
    finder = described_class.instance
    expect(finder.instance_variable_get(:@db)).to eq db
  end

  it "delegates fetch to Db" do
    expect(db).to receive(:fetch).with("ISO 9000", "2015", {})
    described_class.instance.fetch "ISO 9000", "2015", {}
  end

  context "embedded year detection" do
    it "passes year when code has no embedded year" do
      expect(db).to receive(:fetch).with("ISO 9001", "2015", {})
      described_class.instance.fetch "ISO 9001", "2015", {}
    end

    it "drops year when code has embedded year" do
      expect(db).to receive(:fetch).with("ISO 9001:2005", nil, {})
      described_class.instance.fetch "ISO 9001:2005", "2011", {}
    end

    it "handles no year param correctly" do
      expect(db).to receive(:fetch).with("ISO 9001:2005", nil, {})
      described_class.instance.fetch "ISO 9001:2005", nil, {}
    end

    it "passes year when pubid module encounters NameError" do
      finder = described_class.instance
      expect(finder.send(:pubid_module, :relaton_unknown)).to be_nil
    end

    it "handles codes with part numbers but no year" do
      expect(db).to receive(:fetch).with("ISO 19115-2", "2019", {})
      described_class.instance.fetch "ISO 19115-2", "2019", {}
    end

    it "drops year for IEC codes with embedded year" do
      expect(db).to receive(:fetch).with("IEC 60068-2-1:2007", nil, {})
      described_class.instance.fetch "IEC 60068-2-1:2007", "2020", {}
    end

    it "passes year when code has no matching pubid module" do
      expect(db).to receive(:fetch).with("GB/T 12345", "2020", {})
      described_class.instance.fetch "GB/T 12345", "2020", {}
    end

    it "passes year when pubid parse raises" do
      require "pubid/iso"
      allow(Pubid::Iso::Identifier).to receive(:parse).and_raise(StandardError)
      expect(db).to receive(:fetch).with("ISO 9001:2005", "2020", {})
      described_class.instance.fetch "ISO 9001:2005", "2020", {}
    end
  end
end
