class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    room = ChatRoom.find(params[:chat_room_id])
    reject unless current_user.chat_rooms.include?(room)

    stream_for room
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
