class Friendship < ApplicationRecord
  enum status: { pending: 0, accepted: 1, blocked: 2 }

  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :not_self

  private
  
  def not_self
    errors.add(:friend_id, "に自分は指定できません") if user_id == friend_id  
  end
end
