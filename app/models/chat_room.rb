# == Schema Information
#
# Table name: chat_rooms
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ChatRoom < ApplicationRecord
  has_many :messages, dependent: :destroy

  has_many :entries, dependent: :destroy
  has_many :users, through: :entries
  
  validates :name, presence: true

  
  def member?(user)
    entries.exists?(user_id: user.id)
  end
end
