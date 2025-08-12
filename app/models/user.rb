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
end