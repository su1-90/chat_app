class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # 自分から送った申請
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend

  # 自分への申請(逆方向の関連)
  has_many :inverse_friendships,
            class_name: 'Friendship',
            foreign_key: 'friend_id',
            dependent: :destroy
  has_many :inverse_friends, through: :inverse_friendships, source: :user

  validates :username,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { minimum: 3, maximum: 20 }

  def friends
    sent = friendships.accepted.includes(:friend).map(&:friend)
    received = inverse_friendships.accepted.includes(:user).map(&:user)
    sent + received
  end

  # 送信済みの申請を返す
  def sent_friendship_to(other_user)
    friendships.find_by(friend: other_user)
  end

  # 受信済みの申請を返す
  def received_friendship_from(other_user)
    inverse_friendships.find_by(user: other_user)
  end

  # 申請状態をシンボルで返す（:pending / :accepted / :blocked / nil）
  def friendship_status_with(other_user)
    if (f = sent_friendship_to(other_user))
      f.status.to_sym
    elsif (f = received_friendship_from(other_user))
      f.status.to_sym
    else
      nil
    end
  end
end