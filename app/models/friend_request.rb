# == Schema Information
#
# Table name: friend_requests
#
#  id         :bigint           not null, primary key
#  status     :integer          default("pending"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  friend_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_friend_requests_on_friend_id              (friend_id)
#  index_friend_requests_on_user_id                (user_id)
#  index_friend_requests_on_user_id_and_friend_id  (user_id,friend_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (friend_id => users.id)
#  fk_rails_...  (user_id => users.id)
#
class FriendRequest < ApplicationRecord
  enum status: { pending: 0, accepted: 1, rejected: 2 }
  
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validates :user_id, uniqueness: { scope: :friend_id }
  validate :not_self

  private

  def not_self
    errors.add(:friend_id, 'に自分は指定できません') if user_id == friend_id
  end
end
