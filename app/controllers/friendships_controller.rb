class FriendshipsController < ApplicationController
  def create
    friend = User.find(params[:friend_id])
    friendship = current_user.friendships.build(friend: friend, status: :pending)

    if friendship.save
      redirect_to users_path, notice: "#{friend.username} に申請を送りました"
    else
      # save失敗時の理由表示
      redirect_to users_path, alert: friendship.errors.full_messages.to_sentence
    end
  end

  def index
    # 最初に記述したコード
    # @sent_requests = currnet_user.friendships.where(status: :pending)
    # @received_requests = current_user.inverse_friendships.where(status: :pending)
    
    # friendshipsのenumを利用して、簡単に記述
    @sent_requests = current_user.friendships.pending
    @received_requests = current_user.inverse_friendships&.pending || []
  end

  # 友達リストの表示
  def accepted
    # &:friend → do |f| f.friend end の省略記法.
    # Friendshipオブジェクトから関連づけられた「friend(User)」だけを取り出す。=> 「承認済みFriendshipの相手ユーザー」だけを集めた配列になる
    @friends = current_user.friendships.accepted.map(&:friend)
  end
end