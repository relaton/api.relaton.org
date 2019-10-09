class AddExpiresAtToStandards < ActiveRecord::Migration[5.2]
  def change
    add_column :standards, :expires_at, :datetime
  end
end
