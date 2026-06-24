class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    inputs = create_params
    @chat_room = current_user.chat_rooms.find(inputs[:chat_room_id])

    @message = @chat_room.messages.build(
      message_params.merge(user: current_user)
    )

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
    inputs = destroy_params
    @message = current_user.messages.find(inputs[:id])

    if @message.destroy
      render turbo_stream: turbo_stream.remove(@message)
    else
      head :unprocessable_entity
    end
  end

  private

    def create_params
      params.permit(:chat_room_id)
    end

    def message_params
      params.require(:message).permit(:body)
    end

    def destroy_params
      params.permit(:id)
    end
end