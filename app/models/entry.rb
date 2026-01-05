# == Schema Information
#
# Table name: entries
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  chat_room_id :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Entry < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room

  validates :user_id, uniqueness: { scope: :chat_room_id }
end
