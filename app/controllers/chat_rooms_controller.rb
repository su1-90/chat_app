class ChatRoomsController < ApplicationController
  def create
    @chat_room = ChatRoom.new(chat_room_params)

    if @chat_room.save
      @chat_room.entries.create!(user: current_user)
      redirect_to chat_room_path(@chat_room)
    else
      @chat_rooms = ChatRoom.all
      flash.now[:alert] = 'チャットルームを作成できませんでした'
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @chat_room = ChatRoom.find(params[:id]) # 見つからなければApplicationController側へ

    return redirect_to(chat_rooms_path, alert: '権限がありません') unless @chat_room.member?(current_user)

    @messages = @chat_room.messages.includes(:user).order(:created_at)
    @message = Message.new
  end

  private

  def chat_room_params
    params.require(:chat_room).permit(:name)
  end

end