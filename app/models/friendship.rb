class Friendship < ApplicationRecord
  enum status: { active: 0, inactive: 1 }

  has_many :friendship_users, dependent: :destroy
  has_many :users, through: :friendship_users

  scope :alive, -> { where(deleted_at: nil) }

  def self.between(user1, user2)
    alive
      .joins(:friendship_users)
      .where(friendship_users: { user_id: [user1.id, user2.id] })
      .group("friendships.id")
      .having("COUNT(friendship_users.user_id) = 2")
      .first
  end

  def self.status_between(user1, user2)
    friendship = between(user1, user2)
    return :none unless friendship
    friendship.active? ? :friend : :inactive
  end
end
