class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :not_self

  enum status: { active: 0, inactive: 1 }

  def self.status_between(user, other_user)
    friendship = find_by(user: user, friend: other_user ) ||
                  find_by(user: other_user, friend: user)
    return :none unless friendship
    friendship.active? ? :friend : :inactive
  end
  
  private
  
  def not_self
    errors.add(:friend_id, "に自分は指定できません") if user_id == friend_id  
  end
end
