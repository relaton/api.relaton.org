require "rails_helper"

RSpec.describe Standard, type: :model do
  describe ".expired_in" do
    it "returns expired standard upto that time" do
      standard_one = create(:standard, expires_at: 1.days.ago)
      standard_two = create(:standard, expires_at: 1.hours.ago)

      _standard_three = create(:standard, expires_at: 1.hours.from_now)
      _standard_four = create(:standard, expires_at: 4.days.from_now)

      expect(
        Standard.expired_in(1.hours.ago).map(&:id),
      ).to eq([standard_one.id, standard_two.id])
    end
  end
end
