import consumer from "channels/consumer"

const element = document.getElementById('messages')

if (element) {
  const roomId = element.dataset.roomId

  consumer.subscriptions.create(
    { channel: 'ChatRoomChannel', chat_room_id: roomId },
    {
      connected() {
        console.log('ChatRoomChannel connected')
      },

      disconnected() {
        console.log('ChatRoomChannel disconnected')
      },

      received(data) {
        const messages = document.getElementById('messages')
        console.log('message element', messages)
        if (messages) {
          messages.insertAdjacentHTML('beforeend', data.message)
        }
      }
    }
  )
}
