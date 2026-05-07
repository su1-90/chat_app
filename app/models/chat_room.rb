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
  MESSAGES_PER_PAGE = 50

  has_many :messages, dependent: :destroy

  has_many :entries, dependent: :destroy
  has_many :users, through: :entries
  
  # グループでのチャットを想定している.後ほどグループ名の追加を検討
  # validates :name, presence: true

  scope :with_members, ->(user_ids) {
    joins(:entries)
      .where(entries: { user_id: user_ids })
      .group(:id)
      .having('COUNT(entries.id) = ?', user_ids.size)
  }
  
  def self.find_or_create_between_room!(all_user_ids, name: nil)
    transaction do
      sorted_ids = all_user_ids.sort

      room_id = with_members(sorted_ids).pick(:id)
      existing_room = lock.find_by(id: room_id) if room_id
      return existing_room if existing_room

      room = create!(name: name)

      sorted_ids.each do |user_id|
        room.entries.create!(user_id: user_id)
      end

      room
    end
  end

  def display_name_for(viewer)
    return name if name.present?

    partner = users.where.not(id: viewer.id).first
    partner&.username || partner&.email
  end

  def member?(user)
    entries.exists?(user_id: user.id)
  end

  def messages_for_display(page:)
    messages
      .includes(:user)
      .order(created_at: :asc)
      .page(page)
      .per(MESSAGES_PER_PAGE)
  end
end