# == Schema Information
#
# Table name: chat_rooms
#
#  id            :bigint           not null, primary key
#  members_count :integer          default(0), not null
#  name          :string
#  room_type     :integer          default("dm"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_chat_rooms_on_room_type  (room_type)
#
class ChatRoom < ApplicationRecord
  MESSAGES_PER_PAGE = 50
  DM_MEMBERS_COUNT = 2

  enum room_type: { dm: 0, group: 1}, _prefix: true

  has_many :messages, dependent: :destroy

  has_many :entries, dependent: :destroy
  has_many :users, through: :entries


  scope :dm_between, ->(user_a, user_b) {
    room_type_dm
      .joins(:entries)
      .where(entries: { user_id: [user_a.id, user_b.id] }, members_count: DM_MEMBERS_COUNT)
      .group(:id)
      .having('COUNT(entries.id) = ?', DM_MEMBERS_COUNT)
  }

  def self.find_or_create_dm!(user_a, user_b)
    transaction do
      room_id = dm_between(user_a, user_b).pick(:id)
      existing_room = lock.find_by(id: room_id) if room_id
      return existing_room if existing_room

      room = create!(room_type: :dm)
      [user_a, user_b].each { |user| room.entries.create!(user: user) }
      
      room
    end
  end

  def self.create_group!(name:, member_ids:)
    transaction do
      room = create!(name: name, room_type: :group)
      member_ids.each { |id| room.entries.create!(user_id: id) }
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
