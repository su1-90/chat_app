class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  # 現在の友達一覧
  def index
    @friends = current_user.friends
  end

  # 友達解除
  def destroy
    friendship = current_user.friendships.find(params[:id])
    friendship.update!(status: :inactive, deleted_at: Time.current)

    redirect_to friendships_path, notice: "友達を解除しました"
  rescue ActiveRecord::RecordNotFound
    redirect_to friendships_path, alert: "友達が見つかりませんでした"
  end
end
