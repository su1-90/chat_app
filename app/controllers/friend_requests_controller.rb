class FriendRequestsController < ApplicationController
  before_action :authenticate_user!
  def create
    friend = User.find(params[:friend_id])

    @request = current_user.friend_requests.new(friend: friend)

    if @request.save
      redirect_to users_path, notice: "友達申請を送信しました"
    else
      redirect_to users_path, alert: @request.errors.full_messages.to_sentence
    end
  end

  def update
    @friend_request = FriendRequest.find(params[:id])

    case params[:status]
    when "accepted"
      accept_request!
      redirect_to users_path, notice: "友達になりました"
    when "rejected"
      @friend_request.update!(status: :rejected)
      redirect_to users_path, notice: "友達申請を拒否しました"
    else
      redirect_to users_path, alert: "不正な操作です"
    end
  end

  private

  def accept_request!
    ActiveRecord::Base.transaction do
      friendship = Friendship.create!(status: :active)

      FriendshipUser.create!(user: @friend_request.user, friendship: friendship)
      FriendshipUser.create!(user: @friend_request.friend, friendship: friendship)

      @friend_request.update!(status: :accepted)
    end
  end
end
