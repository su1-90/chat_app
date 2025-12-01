class FriendshipUser < ApplicationRecord
  belongs_to :user
  belongs_to :friendship

  validates :user_id, uniqueness: { scope: :friendship_id }
end
