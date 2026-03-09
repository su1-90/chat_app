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
  DM_MEMBER_COUNT = 2

  has_many :messages, dependent: :destroy

  has_many :entries, dependent: :destroy
  has_many :users, through: :entries
  
  # グループでのチャットを想定している.後ほどグループ名の追加を検討
  # validates :name, presence: true

  scope :dm_between, ->(user_a_id, user_b_id) {
    joins(:entries)
      .where(entries: { user_id: [user_a_id, user_b_id] })
      .group(:id)
      .having('COUNT(DISTINCT entries.user_id) = ?', DM_MEMBER_COUNT)
      .having('COUNT(entries.id) = ?', DM_MEMBER_COUNT)
  }
  
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