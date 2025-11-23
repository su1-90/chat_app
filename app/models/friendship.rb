class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  before_validation :normalize_user_ids

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :not_self

  enum status: { active: 0, inactive: 1 }

  scope :alive, -> { where(deleted_at: nil) }

  def self.between(user, other_user)
    ids = [user.id, other_user.id].sort
    alive.find_by(user_id: ids[0], friend_id: ids[1])
  end

  def other_for(user)
    user_id == user.id ? frined : user
  end

  private

  def normalize_user_ids
    return if user_id.blank? || friend_id.blank?

    if user_id > friend_id
      self.user_id, self.friend_id = friend_id, user_id
    end
  end

  def not_self
    errors.add(:friend_id, "に自分は指定できません") if user_id == friend_id
  end
end
