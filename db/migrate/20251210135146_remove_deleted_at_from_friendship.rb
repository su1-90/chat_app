class RemoveDeletedAtFromFriendship < ActiveRecord::Migration[7.1]
  def change
    remove_column :friendships, :deleted_at, :datetime
  end
end
