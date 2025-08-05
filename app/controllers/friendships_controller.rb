class FriendshipsController < ApplicationController
  def create
    friend = User.find(params[:friend_id])
    friendship = current_user.friendships.build(friend: friend, status: :pending)

    if friendship.save
      redirect_to users_path, notice: "#{friend.username} に申請を送りました"
    else
      redirect_to users_path, alert: "申請に失敗しました"
    end
  end

  def index
    @sent_requests = currnet_user.friendships.where(status: :pending)
    @received_requests = current_user.inverse_friendships.where(status: :pending)
  end
end