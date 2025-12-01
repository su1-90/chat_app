class CreateFriendshipUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :friendship_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :friendship, null: false, foreign_key: true

      t.timestamps
    end

    add_index :friendship_users, [:user_id, :friendship_id], unique: true
  end
end
