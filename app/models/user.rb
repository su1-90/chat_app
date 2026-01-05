# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  name                   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string           default(""), not null
#
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :friendship_users, dependent: :destroy
  has_many :friendships, through: :friendship_users

  has_many :friend_requests, dependent: :destroy
  has_many :received_friend_requests,
            class_name: 'FriendRequest',
            foreign_key: 'friend_id',
            dependent: :destroy

  has_many :messages, dependent: :destroy

  has_many :entries, dependent: :destroy
  has_many :chat_rooms, through: :entries

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 20 }

  def friends
    friendships.active
                .includes(:users)
                .flat_map(&:users)
                .uniq
                .reject { |u| u.id == id }
  end

  # 友達かどうかの判定
  def friend_with?(other_user)
    friendship_with(other_user).present?
  end

  # 友達関係のレコード取得
  def friendship_with(other_user)
    return if other_user == self

    common_ids = 
      friendship_users
        .select(:friendship_id)
        .where(friendship_id: other_user.friendship_users.select(:friendship_id))

    friendships.active.find_by(id: common_ids)
  end

  # 自分が送った申請（FriendRequest）
  def sent_request_to(other_user)
    friend_requests.find_by(friend: other_user)
  end

  # 自分が受け取った申請（FriendRequest）
  def received_request_from(other_user)
    received_friend_requests.find_by(user: other_user)
  end


end
