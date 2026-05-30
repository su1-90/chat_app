class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat_room = ChatRoom.find(chat_room_id)

    unless @chat_room.member?(current_user)
      return head :forbidden
    end

    @message = @chat_room.messages.build(message_params.merge(user: current_user))

    if @message.save
      @message = Message.new

      render turbo_stream: turbo_stream.update(
        'message_form',
        partial: 'messages/form',
        locals: { chat_room: @chat_room, message: @message }
      )
    else
      render turbo_stream: turbo_stream.update(
        'message_form',
        partial: 'messages/form',
        locals: { chat_room: @chat_room, message: @message }
      ), status: :unprocessable_entity
    end
  end
  
  def destroy
    @chat_room = ChatRoom.find(chat_room_id)
    @message = @chat_room.messages.find(destroy_params)

    if @message.user_id == current_user.id
      @message.destroy
      render turbo_stream: turbo_stream.remove(@message)
    else
      head :forbidden
    end
  end

  private

    def chat_room_id
      params[:chat_room_id]
    end
  
    def message_params
      params.require(:message).permit(:body)
    end
  
    def destroy_params
      params[:id]
    end
end
