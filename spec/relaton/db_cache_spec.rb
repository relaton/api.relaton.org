RSpec.describe Relaton::DbCache do
  subject { Relaton::DbCache.new "cache" }

  it "delete item" do
    expect(subject).to receive(:delete).with("key")
    subject["key"] = nil
  end

  it "call Relaton::Storage#all method" do
    expect(Relaton::Storage.instance).to receive(:all).with "cache"
    subject.all
  end

  it "call Relaon::Storage#check_version? method" do
    fdir = "cache/iso/"
    expect(Relaton::Storage.instance).to receive(:check_version?).with fdir
    subject.check_version? fdir
  end

  it "call Relaton::Storage#delete with list of files" do
    storage = subject.instance_variable_get :@storage
    expect(storage).to receive(:ls).with("cache", files: false).and_return ["cache/iso/"]
    expect(storage).to receive(:check_version?).with("cache/iso/").and_return false
    expect(storage).to receive(:ls).with("cache/iso/", dirs: false).and_return ["cache/iso/iso_1.xml"]
    expect(storage).to receive(:delete).with ["cache/iso/iso_1.xml"]
    subject.check_all_versions?
  end
end
