class DirectMessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    target_user = current_user.friends.find { |u| u.id == params[:user_id].to_i }

    raise ActiveRecord::RecordNotFound, "Friend not found" unless target_user

    room = ChatRoom.find_or_create_dm!(current_user, target_user)
    redirect_to chat_room_path(room)
  end
end
