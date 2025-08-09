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
    @receives_requests = current_user.inverse_friendships.pending
  end
end