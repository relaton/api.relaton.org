describe Relaton::Db do
  let(:gdb) { double "gdb" }
  let(:ldb) { double "ldb" }

  subject do
    expect(gdb).to receive(:check_all_versions?)
    expect(Relaton::DbCache).to receive(:new).with("global_cache", "xml").and_return gdb
    expect(ldb).to receive(:check_all_versions?)
    expect(Relaton::DbCache).to receive(:new).with("local_cache", "xml").and_return ldb
    described_class.new "global_cache", "local_cache"
  end

  it "initialize" do
    expect(subject.instance_variable_get(:@registry)).to be_instance_of Relaton::Registry
    expect(subject.instance_variable_get(:@db)).to eq gdb
    expect(subject.instance_variable_get(:@local_db)).to eq ldb
    expect(subject.instance_variable_get(:@static_db)).to be_nil
    expect(subject.instance_variable_get(:@queues)).to eq({})
  end

  context "class methods" do
    it "global_bibliocache_name" do
      expect(described_class.send(:global_bibliocache_name)).to eq "cache"
    end

    it "local_bibliocache_name" do
      expect(described_class.send(:local_bibliocache_name, "cachename")).to be_nil
    end
  end
end
