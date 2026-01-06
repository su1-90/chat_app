# == Schema Information
#
# Table name: friendship_users
#
#  id            :bigint           not null, primary key
#  user_id       :bigint           not null
#  friendship_id :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class FriendshipUser < ApplicationRecord
  belongs_to :user
  belongs_to :friendship

  validates :user_id, uniqueness: { scope: :friendship_id }
end
