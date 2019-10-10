class Standard < ApplicationRecord
  def self.expired_in(timestamp)
    where("expires_at <= ?", timestamp)
  end
end
