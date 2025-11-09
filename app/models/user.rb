class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # 自分から送った友達関係
  has_many :friendships, dependent: :destroy

  # 自分への友達関係
  has_many :inverse_friendships,
           class_name: 'Friendship',
           foreign_key: 'friend_id',
           dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user

  # 友達申請
  has_many :friend_requests, dependent: :destroy
  has_many :received_friend_requests,
           class_name: "FriendRequest",
           foreign_key: "friend_id",
           dependent: :destroy

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 20 }

  # 現在の友達一覧
  def friends
    friendships.includes(:friend).map(&:friend) +
      inverse_friendships.includes(:user).map(&:user)
  end

  # 自分が送った申請（FriendRequest）
  def sent_request_to(other_user)
    friend_requests.find_by(friend: other_user)
  end

  # 自分が受け取った申請（FriendRequest）
  def received_request_from(other_user)
    received_friend_requests.find_by(user: other_user)
  end

  # 友達であるかどうかの判定
  def friend_with?(other_user)
    friends.include?(other_user)
  end

  # 相手との関係状態を返す
  def friendship_status_with(other_user)
    return :self if self == other_user
    return :friend if friend_with?(other_user)

    if sent_request_to(other_user)&.pending?
      return :request_sent
    elsif received_request_from(other_user)&.pending?
      return :request_received
    elsif sent_request_to(other_user)&.rejected?
      return :request_rejected
    end

    :none
  end
end