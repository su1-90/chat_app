# == Schema Information
#
# Table name: messages
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  chat_room_id :bigint           not null
#  body         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room

  validates :body, presence: true, length: { maximum: 100 }
end
