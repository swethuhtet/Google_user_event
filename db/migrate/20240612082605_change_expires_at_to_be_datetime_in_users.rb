class ChangeExpiresAtToBeDatetimeInUsers < ActiveRecord::Migration[7.1]
  def up
    change_column :users, :expires_at, :datetime
  end

  def down
    change_column :users, :expires_at, :string
  end
end
