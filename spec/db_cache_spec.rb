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
    expect(Relaton::Storage.instance).to receive(:check_version?).with "cache/iso"
    subject.check_version? "cache/iso"
  end
end
