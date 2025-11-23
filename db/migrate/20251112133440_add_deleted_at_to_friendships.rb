class AddDeletedAtToFriendships < ActiveRecord::Migration[7.1]
  def change
    add_column :friendships, :deleted_at, :datetime
  end
end
