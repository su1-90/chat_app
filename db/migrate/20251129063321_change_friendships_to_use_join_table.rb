class ChangeFriendshipsToUseJoinTable < ActiveRecord::Migration[7.1]
  def change
    remove_reference :friendships, :user, foreign_key: true
    remove_reference :friendships, :friend, foreign_key: { to_table: :users }
  end
end
