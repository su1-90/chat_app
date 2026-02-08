class MessagesController < ApplicationController
  before_action :authenticate_user!

  def create
    @chat_room = ChatRoom.find(params[:chat_room_id])

    # 権限チェックが増えたらbefore_actionに切り出す
    unless @chat_room.member?(current_user)
      return redirect_to chat_rooms_path, alert: '権限がありません'
    end

    @message = @chat_room.messages.build(message_params.merge(user: current_user))

    if @message.save
      redirect_to @chat_room
    else
      # 安定運用できてきたら無限スクロールを検討する
      @messages = @chat_room.messages_for_display(page: params[:page], per_page: 50)
      flash.now[:alert] = 'メッセージを送信できませんでした'
      render 'chat_rooms/show', status: :unprocessable_entity
    end
  end
  
  
  private
  
  def message_params
    params.require(:message).permit(:body)
  end
  
end
