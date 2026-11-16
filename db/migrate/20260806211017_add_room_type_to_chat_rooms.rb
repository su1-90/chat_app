class AddRoomTypeToChatRooms < ActiveRecord::Migration[7.1]
  def change
    add_column :chat_rooms, :room_type, :integer, null: false, default: 0
    add_index :chat_rooms, :room_type

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE chat_rooms
          SET room_type = 1
          WHERE (name IS NOT NULL AND name != '')
             OR members_count <> 2;
        SQL
      end
    end
  end
end
