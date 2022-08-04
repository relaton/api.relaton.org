RSpec.describe Relaton::DbCache do
  subject { Relaton::DbCache.new "cache" }

  it "initialize" do
    expect(subject.instance_variable_get(:@dir)).to eq "cache"
    expect(subject.instance_variable_get(:@ext)).to eq "xml"
    expect(subject.instance_variable_get(:@storage)).to be_instance_of Relaton::Storage
  end

  context "instance methods" do
    let(:storage) { subject.instance_variable_get(:@storage) }

    context "#[]=" do
      it "update item" do
        doc = "<doc>Test doc</doc>"
        expect(storage).to receive(:save_version).with("cache/iso", kind_of(String))
        expect(storage).to receive(:save).with("cache/iso/iso_123.xml", doc)
        subject["ISO(ISO 123)"] = doc
      end

      it "delete item" do
        expect(subject).to receive(:delete).with("key")
        subject["key"] = nil
      end
    end

    context "#delete" do
      it "key found" do
        expect(storage).to receive(:search_ext).with("iso_123.xml").and_return "iso_123.xml"
        expect(storage).to receive(:delete).with("cache/iso_123.xml")
        subject.delete "iso_123.xml"
      end

      it "key not found" do
        expect(storage).to receive(:search_ext).with("iso_123.xml").and_return nil
        expect(storage).not_to receive(:delete)
        subject.delete "iso_123.xml"
      end
    end

    context "#get" do
      it "static db" do
        subject.instance_variable_set(:@ext, "yml")
        expect(subject).to receive(:search_ext).with("cache/iso_123").and_return "cache/iso_123.yml"
        expect(File).to receive(:read).with("cache/iso_123.yml", encoding: "utf-8").and_return :doc
        expect(subject.get("iso_123")).to eq :doc
      end

      it "found" do
        expect(storage).to receive(:search_ext).with("cache/iso_123").and_return "cache/iso_123.xml"
        expect(storage).to receive(:get).with("cache/iso_123.xml").and_return :doc
        expect(subject.get("iso_123")).to eq :doc
      end

      it "not found" do
        expect(storage).to receive(:search_ext).with("cache/iso_123").and_return nil
        expect(storage).not_to receive(:get)
        expect(subject.get("iso_123")).to be_nil
      end
    end

    it "call Relaton::Storage#all method" do
      expect(Relaton::Storage.instance).to receive(:all).with "cache"
      subject.all
    end

    it "call Relaon::Storage#check_version? method" do
      fdir = "cache/iso/"
      expect(Relaton::Storage.instance).to receive(:get_version).with fdir
      subject.check_version? fdir
    end

    it "call Relaton::Storage#delete with list of files" do
      expect(storage).to receive(:ls_dir).with("cache").and_return ["cache/iso/"]
      expect(storage).to receive(:get_version).with("cache/iso/").and_return false
      expect(storage).to receive(:ls).with("cache/iso/").and_return ["cache/iso/iso_1.xml"]
      expect(storage).to receive(:delete).with ["cache/iso/iso_1.xml"]
      subject.check_all_versions?
    end
  end
end
