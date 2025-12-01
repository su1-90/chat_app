class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  has_many :friendship_users, dependent: :destroy
  has_many :friendships, through: :friendship_users

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

  def friend_with?(other_user)
    Friendship.status_between(self, other_user) == :friend
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