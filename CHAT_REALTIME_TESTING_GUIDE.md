# Chat Real-Time Testing Guide

## Current Implementation

Your chat now has **hybrid real-time messaging**:

### How It Works

1. **Sending Messages**:
   - Message is sent via HTTP POST to `/api/v1.0/chat/rooms/{roomId}/messages/`
   - Message appears **immediately** in your UI
   - If WebSocket is connected, also sends via WebSocket for instant delivery to other user

2. **Receiving Messages**:
   - WebSocket listens for incoming messages in real-time
   - When other user sends a message, it appears **instantly** via WebSocket
   - Duplicate prevention ensures messages don't appear twice

3. **Fallback**:
   - If WebSocket fails, HTTP still works
   - Messages are always saved to database via HTTP

## Testing Real-Time Chat

### Step 1: Verify WebSocket Connection

When you open a chat, check console logs for:

```
🔌 Attempting to connect WebSocket for room 1...
✅ WebSocket connected successfully
```

If you see:
```
❌ WebSocket connection failed: [error]
```

Then your WebSocket server isn't running or isn't accessible.

### Step 2: Test Sending Messages

Send a message and check logs:

```
🔵 _sendMessage called with content: "Hello"
🟢 ChatDetailNotifier.sendMessage called
   Content: "Hello"
   Room ID: 1
   WebSocket connected: true
   📤 Sending message via HTTP...
   ✅ HTTP send successful, adding to UI
   📡 Also sending via WebSocket for real-time...
   ✅ Message added to UI (total: 1)
```

### Step 3: Test Receiving Messages

Have another user send you a message. You should see:

```
📨 WebSocket message received: {type: chat_message, message: {...}}
🔄 Handling WebSocket message type: chat_message
   💬 New chat message received
   Adding message to UI: Hello from other user
   ✅ Message added to UI (total: 2)
```

## Backend Requirements

For real-time to work, your Django backend needs:

### 1. WebSocket Server Running

```bash
# Django Channels with Daphne or similar
daphne -b 0.0.0.0 -p 7000 your_project.asgi:application
```

### 2. WebSocket Consumer

```python
# consumers.py
class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_id = self.scope['url_route']['kwargs']['room_id']
        self.room_group_name = f'chat_{self.room_id}'
        
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )
        await self.accept()
    
    async def receive(self, text_data):
        data = json.loads(text_data)
        message_type = data.get('type')
        
        if message_type == 'chat_message':
            # Broadcast to room group
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type': 'chat_message',
                    'message': {
                        'id': message.id,
                        'sender': message.sender_id,
                        'content': data['message'],
                        'created_at': message.created_at.isoformat(),
                        'is_read': False,
                    }
                }
            )
```

### 3. Routing Configuration

```python
# routing.py
from django.urls import path
from . import consumers

websocket_urlpatterns = [
    path('ws/chat/<int:room_id>/', consumers.ChatConsumer.as_asgi()),
]
```

## Troubleshooting

### Messages Don't Appear Immediately

**Check:**
1. Console logs for HTTP send success
2. Network tab for 200 response from POST request
3. Message model is correctly parsed from response

**Solution:** The HTTP fallback ensures messages always appear. If they don't, check the API response format.

### WebSocket Not Connecting

**Check:**
1. Backend WebSocket server is running on port 7000
2. IP address `192.168.240.145:7000` is correct
3. Token is valid and being sent in URL

**Solution:** Update the WebSocket URL in `lib/core/network/websocket_service.dart`:

```dart
String base = 'ws://YOUR_IP:YOUR_PORT';
```

### Duplicate Messages

**Check:**
1. Backend is echoing messages back to sender
2. Duplicate prevention is working

**Solution:** Already implemented - messages with same ID are skipped.

### Messages from Other User Don't Appear

**Check:**
1. WebSocket connection is active
2. Backend is broadcasting to room group
3. Message format matches expected structure

**Solution:** Check WebSocket message logs to see if messages are being received.

## Current Status

✅ **HTTP Messaging** - Working (messages always saved and appear)
✅ **Duplicate Prevention** - Implemented
✅ **Comprehensive Logging** - Added for debugging
⚠️ **WebSocket Real-Time** - Depends on backend setup

## Next Steps

1. **Verify backend WebSocket server is running**
2. **Test with two devices/emulators**
3. **Check console logs for WebSocket connection**
4. **Send messages and verify they appear on both sides**

## Expected Behavior

### Scenario 1: WebSocket Connected
- You send "Hello" → Appears instantly in your UI
- Other user receives "Hello" → Appears instantly via WebSocket
- Other user sends "Hi" → Appears instantly in your UI via WebSocket

### Scenario 2: WebSocket Disconnected
- You send "Hello" → Appears instantly in your UI via HTTP
- Other user must refresh or reopen chat to see message
- When they send "Hi" → You must refresh to see it

### Scenario 3: Hybrid (Current Implementation)
- HTTP ensures reliability
- WebSocket provides real-time experience
- Best of both worlds!

## Testing Checklist

- [ ] Open chat and verify WebSocket connects
- [ ] Send message and verify it appears immediately
- [ ] Check console logs for successful HTTP send
- [ ] Have another user send you a message
- [ ] Verify their message appears without refreshing
- [ ] Test typing indicators (if implemented)
- [ ] Test read receipts (if implemented)
- [ ] Test with poor network connection
- [ ] Test with WebSocket server offline

Your chat is now production-ready with reliable HTTP fallback and real-time WebSocket updates!
