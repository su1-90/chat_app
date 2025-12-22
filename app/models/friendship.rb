class Friendship < ApplicationRecord
  enum status: { active: 0, inactive: 1 }

  has_many :friendship_users, dependent: :destroy
  has_many :users, through: :friendship_users

end
