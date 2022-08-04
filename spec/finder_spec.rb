describe Relaton::Finder do
  let(:db) { double "db" }

  before do
    Singleton.__init__(Relaton::Finder)
    config = double "config"
    expect(config).to receive(:use_api=).with false
    expect(Relaton).to receive(:configure).and_yield config
    expect(Relaton::Db).to receive(:init_bib_caches).with(global_cache: true).and_return db
  end

  it "initialize" do
    finder = described_class.instance
    expect(finder.instance_variable_get(:@db)).to eq db
  end

  it "fetch" do
    expect(db).to receive(:fetch).with("code", "year", "opts")
    described_class.instance.fetch "code", "year", "opts"
  end
end
