class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  # 現在の友達一覧
  def index
    @friends = current_user.friends
  end

  # 友達解除
  def destroy
  friendship = current_user.friendships.find(params[:id]) ||
               Friendship.find_by(user: params[:id], friend: current_user)

  friendship.update!(status: :inactive, deleted_at: Time.current)
  redirect_to friendships_path, notice: "友達を解除しました"
  end
end
