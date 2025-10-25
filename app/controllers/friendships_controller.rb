class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  # 現在の友達一覧
  def index
    @friends = current_user.friends
  end

  # 友達解除
  def destroy
    friendship = Friendship.find_by(id: params[:id])

    unless friendship && [friendship.user_id, friendship.friend_id].include?(current_user.id)
      redirect_back fallback_location: friendships_path, alert: "操作権限がありません。"
      return
    end

    if friendship.destroy
      redirect_back fallback_location: friendships_path, notice: "友達を解除しました"
    else
      redirect_back fallback_location: friendships_path, alert: "解除に失敗しました。"
    end
  end
end
