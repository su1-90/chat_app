# == Schema Information
#
# Table name: friendships
#
#  id         :bigint           not null, primary key
#  status     :integer          default("active"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Friendship < ApplicationRecord
  enum status: { active: 0, inactive: 1 }

  has_many :friendship_users, dependent: :destroy
  has_many :users, through: :friendship_users

end
