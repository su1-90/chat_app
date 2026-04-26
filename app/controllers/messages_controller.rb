class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat_room = ChatRoom.find(chat_room_id)

    # 権限チェックが増えたらbefore_actionに切り出す
    unless @chat_room.member?(current_user)
      return head :forbidden
    end

    @message = @chat_room.messages.build(message_params.merge(user: current_user))

    if @message.save
      head :no_content
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end
  

  private

    def chat_room_id
      params[:chat_room_id]
    end
  
    def message_params
      params.require(:message).permit(:body)
    end
  
end
