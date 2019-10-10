require "rails_helper"

RSpec.describe "relaton:cleanup" do
  include_context "rake"

  it "removes all expired document" do
    _standard_one = create(:standard, expires_at: 1.days.ago)
    _standard_two = create(:standard, expires_at: 5.days.ago)

    standard_three = create(:standard, expires_at: 1.hours.from_now)
    standard_four = create(:standard, expires_at: 1.days.from_now)

    subject.invoke

    expect(Standard.count).to eq(2)
    expect(Standard.all.map(&:id)).to eq([standard_three.id, standard_four.id])
  end
end
