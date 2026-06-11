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
end
