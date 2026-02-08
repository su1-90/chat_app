class ChatRoomsController < ApplicationController
  before_action :authenticate_user!

  def index
    @chat_room = ChatRoom.new
    @chat_rooms = get_chat_rooms
  end

  def create
    @chat_room = ChatRoom.new(chat_room_params)

    if @chat_room.save
      @chat_room.entries.create!(user: current_user)
      redirect_to @chat_room, flash: { notice: 'チャットルームを作成しました' }
    else
      @chat_rooms = get_chat_rooms
      flash.now[:alert] = 'チャットルームを作成できませんでした'
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @chat_room = ChatRoom.find_by(id: params[:id])
    return redirect_to(chat_rooms_path, alert: 'チャットルームが見つかりません') unless @chat_room

    return redirect_to(chat_rooms_path, alert: '権限がありません') unless @chat_room.member?(current_user)

    @messages = @chat_room.messages
                          .includes(:user)
                          .order(created_at: :desc)
                          .page(params[:page])
                          .per(50)
    @message = @chat_room.messages.build(user: current_user)
  end

  private

    def chat_room_params
      params.require(:chat_room).permit(:name)
    end

    def get_chat_rooms
      current_user.chat_rooms
                  .distinct
                  .order(created_at: :desc)
                  .page(params[:page])
                  .per(50)
    end
end