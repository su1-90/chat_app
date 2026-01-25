class ChatRoomsController < ApplicationController
  def show
    @chat_room = ChatRoom.find(params[:id]) # 見つからなければApplicationController側へ

    return redirect_to(chat_rooms_path, alert: '権限がありません') unless @chat_room.member?(current_user)

    @messages = @chat_room.messages.includes(:user).order(:created_at)
    @message = Message.new
  end
end