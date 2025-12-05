# Real-Time Matching System Guide

## Overview
This guide explains how the real-time matching system works in HeartLink, from swiping to instant match notifications and chat room creation.

## How Matching Works

### 1. **The Swipe Action**
When a user swipes right (likes) on a profile:

```
User A swipes right on User B
    ↓
API Call: POST /interactions/like/{profile_id}
    ↓
Backend checks: Has User B already liked User A?
    ↓
    ├─ YES → It's a Match! 🎉
    │   ├─ Create chat room
    │   ├─ Send match notification to both users
    │   └─ Return match data with room_id
    │
    └─ NO → Store like
        └─ Send notification to User B
```

### 2. **Match Detection (Backend)**
The backend automatically detects matches when:
- User A likes User B
- User B has already liked User A (mutual like)

**Backend Logic:**
```python
# Simplified backend logic
def create_like(user_a, user_b):
    # Check if User B already liked User A
    existing_like = Like.objects.filter(
        from_user=user_b,
        to_user=user_a
    ).first()
    
    if existing_like:
        # It's a match!
        match = Match.objects.create(
            user1=user_a,
            user2=user_b
        )
        
        # Create chat room
        room = ChatRoom.objects.create(
            match=match
        )
        
        # Send real-time notifications
        send_match_notification(user_a, user_b, room.id)
        
        return {'is_match': True, 'room_id': room.id}
    else:
        # Just a like
        Like.objects.create(from_user=user_a, to_user=user_b)
        return {'is_match': False}
```

### 3. **Real-Time Notifications**

#### WebSocket Connection
The app maintains a WebSocket connection for real-time updates:

```dart
// lib/core/network/websocket_service.dart
class WebSocketService {
  IOWebSocketChannel? _channel;
  
  void connect(String token) {
    _channel = IOWebSocketChannel.connect(
      'ws://your-api.com/ws/notifications/',
      headers: {'Authorization': 'Bearer $token'},
    );
    
    _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      _handleNotification(data);
    });
  }
  
  void _handleNotification(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'new_match':
        _showMatchScreen(data);
        break;
      case 'new_message':
        _updateChatList(data);
        break;
      case 'new_like':
        _updateLikesCount(data);
        break;
    }
  }
}
```

#### Match Notification Flow
```
Backend detects match
    ↓
Send WebSocket message to both users
    ↓
{
  "type": "new_match",
  "match_id": 123,
  "room_id": 456,
  "other_user": {
    "id": 789,
    "name": "Sarah",
    "photo": "https://..."
  }
}
    ↓
App receives notification
    ↓
Show MatchPage with animation
```

### 4. **Match Page Flow**

```dart
// When match is detected
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => MatchPage(
      profileName: otherUser.name,
      profilePhoto: otherUser.photo,
      roomId: match.roomId,  // Important: Room ID from match
    ),
  ),
);
```

**User Actions on Match Page:**
1. **Write a message** → Sends message → Navigate to ChatDetailPage
2. **Use quick reply** → Fills message → User can edit → Send
3. **Keep Swiping** → Close match page → Continue discovering

### 5. **Chat Room Creation**

When a match occurs, the backend automatically:
1. Creates a `Match` record
2. Creates a `ChatRoom` linked to the match
3. Returns the `room_id` to both users

**Chat Room Structure:**
```json
{
  "id": 456,
  "match_id": 123,
  "participants": [
    {"id": 1, "name": "John"},
    {"id": 2, "name": "Sarah"}
  ],
  "created_at": "2024-01-15T10:30:00Z",
  "last_message": null,
  "unread_count": 0
}
```

### 6. **Message Sending from Match Page**

```dart
// In match_page.dart
Future<void> _sendMessageAndNavigate() async {
  final message = _messageController.text.trim();
  
  if (message.isEmpty) {
    _navigateToChat();  // Just open chat
    return;
  }

  setState(() => _isSending = true);

  try {
    // Send message to the chat room
    await ref
        .read(chatDetailProvider(widget.roomId).notifier)
        .sendMessage(message);

    // Navigate to chat detail page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(roomId: widget.roomId),
      ),
    );
  } catch (e) {
    // Handle error
    CustomSnackbar.show(
      context,
      message: 'Failed to send message',
      type: SnackbarType.error,
    );
  }
}
```

### 7. **Real-Time Message Delivery**

Once in the chat:
```
User A sends message
    ↓
POST /chat/rooms/{room_id}/messages/
    ↓
Backend saves message
    ↓
WebSocket broadcast to User B
    ↓
{
  "type": "new_message",
  "room_id": 456,
  "message": {
    "id": 789,
    "content": "Hey! How are you?",
    "sender": 1,
    "created_at": "2024-01-15T10:35:00Z"
  }
}
    ↓
User B's app receives message
    ↓
Update chat UI in real-time
```

## Complete Matching Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    User A Swipes Right                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              API: POST /interactions/like/{id}               │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│         Backend: Check if User B liked User A                │
└────────┬────────────────────────────────────────────┬───────┘
         │                                             │
    YES (Match!)                                  NO (Just Like)
         │                                             │
         ▼                                             ▼
┌────────────────────┐                    ┌──────────────────────┐
│  Create Match      │                    │  Store Like          │
│  Create ChatRoom   │                    │  Notify User B       │
│  room_id: 456      │                    │  "Someone liked you" │
└────────┬───────────┘                    └──────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│         WebSocket: Send match notification to both           │
│         {type: "new_match", room_id: 456, ...}              │
└────────┬────────────────────────────────────────────┬───────┘
         │                                             │
    User A App                                    User B App
         │                                             │
         ▼                                             ▼
┌────────────────────┐                    ┌──────────────────────┐
│  Show MatchPage    │                    │  Show MatchPage      │
│  with User B info  │                    │  with User A info    │
└────────┬───────────┘                    └──────────┬───────────┘
         │                                             │
         ▼                                             ▼
┌────────────────────┐                    ┌──────────────────────┐
│  User writes msg   │                    │  User writes msg     │
│  "Hey! 👋"         │                    │  "Hi there! 😊"      │
└────────┬───────────┘                    └──────────┬───────────┘
         │                                             │
         ▼                                             ▼
┌────────────────────┐                    ┌──────────────────────┐
│  Send & Navigate   │                    │  Send & Navigate     │
│  to ChatDetail     │                    │  to ChatDetail       │
└────────┬───────────┘                    └──────────┬───────────┘
         │                                             │
         └──────────────────┬──────────────────────────┘
                            ▼
              ┌──────────────────────────┐
              │   Both users in chat     │
              │   Real-time messaging    │
              └──────────────────────────┘
```

## Key Components

### 1. **EncountersProvider**
Handles swipe actions and match detection:
```dart
Future<void> likeProfile(int profileId) async {
  final result = await _repository.likeProfile(profileId);
  
  if (result.isMatch) {
    // Show match page
    _showMatchPage(result.matchData);
  }
}
```

### 2. **MatchesProvider**
Manages the list of matches:
```dart
Future<void> loadMatches() async {
  final matches = await _repository.getMatches();
  state = state.copyWith(matches: matches);
}
```

### 3. **ChatProvider**
Manages chat rooms and messages:
```dart
Future<void> loadChatRooms() async {
  final rooms = await _repository.getChatRooms();
  state = state.copyWith(rooms: rooms);
}
```

### 4. **WebSocketService**
Handles real-time notifications:
```dart
void connect(String token) {
  // Connect to WebSocket
  // Listen for notifications
  // Update UI in real-time
}
```

## Testing Real-Time Matching

### Manual Testing Steps:
1. **Setup Two Devices/Emulators**
   - Device A: User John
   - Device B: User Sarah

2. **Test Match Flow:**
   ```
   Step 1: John swipes right on Sarah
   Step 2: Sarah swipes right on John
   Step 3: Both see MatchPage simultaneously
   Step 4: John sends "Hey!"
   Step 5: Sarah sees message in real-time
   ```

3. **Verify:**
   - ✅ Match page appears on both devices
   - ✅ Chat room is created
   - ✅ Messages sync in real-time
   - ✅ Unread counts update
   - ✅ Match appears in "New Matches" section

## Common Issues & Solutions

### Issue 1: Match not detected
**Cause:** WebSocket not connected
**Solution:** Check WebSocket connection status

### Issue 2: Delayed notifications
**Cause:** Network latency or WebSocket reconnection
**Solution:** Implement retry logic and connection monitoring

### Issue 3: Duplicate match pages
**Cause:** Multiple swipe events
**Solution:** Debounce swipe actions

## Best Practices

1. **Always pass `roomId` to MatchPage**
   ```dart
   MatchPage(
     profileName: name,
     profilePhoto: photo,
     roomId: match.roomId,  // Required!
   )
   ```

2. **Handle WebSocket disconnections**
   ```dart
   void _handleDisconnection() {
     // Attempt reconnection
     // Fetch missed notifications via API
   }
   ```

3. **Optimize match detection**
   - Cache recent likes locally
   - Batch notification processing
   - Use efficient database queries

4. **User Experience**
   - Show loading states
   - Handle errors gracefully
   - Provide offline support
   - Animate transitions smoothly

## API Endpoints Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/interactions/like/{id}` | POST | Like a profile, returns match status |
| `/interactions/matches/` | GET | Get all matches |
| `/chat/rooms/` | GET | Get all chat rooms |
| `/chat/rooms/{id}/messages/` | GET/POST | Get/send messages |
| `/ws/notifications/` | WebSocket | Real-time notifications |

## Conclusion

The real-time matching system provides instant feedback and seamless transitions from discovery to conversation. By combining REST API calls with WebSocket notifications, users experience immediate match notifications and can start chatting right away.
