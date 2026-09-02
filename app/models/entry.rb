# == Schema Information
#
# Table name: entries
#
#  id           :bigint           not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  chat_room_id :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_entries_on_chat_room_id              (chat_room_id)
#  index_entries_on_user_id                   (user_id)
#  index_entries_on_user_id_and_chat_room_id  (user_id,chat_room_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (chat_room_id => chat_rooms.id)
#  fk_rails_...  (user_id => users.id)
#
class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room, counter_cache: :members_count

  validates :user_id, uniqueness: { scope: :chat_room_id }
end
