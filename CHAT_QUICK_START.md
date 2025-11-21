# 💬 Chat System - Quick Start Guide

## Installation

### 1. Install Dependencies

```bash
flutter pub get
```

This will install the new `timeago` package for time formatting.

### 2. Verify Backend Configuration

Check your `.env.development` file:

```env
API_BASE_URL=http://localhost:8000
```

For production, use your actual backend URL:

```env
API_BASE_URL=https://api.yourdomain.com
```

## Usage

### Opening Chat List

The chat list is already integrated in your main navigation. Users can access it from the Messages tab.

```dart
// The chat page automatically loads when navigating to it
// No additional setup needed!
```

### Opening a Chat Conversation

```dart
// From chat list, tap on any conversation
// Or programmatically:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatDetailPage(roomId: 123),
  ),
);
```

## Features

### Real-Time Messaging

Messages are sent and received instantly via WebSocket:

```dart
// Automatically handled by ChatDetailNotifier
// Just type and press send!
```

### Typing Indicators

Shows when the other person is typing:

```dart
// Automatically sent when user types
// Stops after 3 seconds of inactivity
```

### Read Receipts

Double checkmarks show when messages are read:

```dart
// ✓✓ Gray = Delivered
// ✓✓ Green = Read
```

### Message Pagination

Load older messages by scrolling to the top:

```dart
// Automatically loads more when reaching the top
// Shows loading indicator while fetching
```

## API Endpoints

The chat system uses these endpoints:

```
GET  /api/v1.0/chat/rooms/                    # List chat rooms
GET  /api/v1.0/chat/rooms/{id}/               # Room details
GET  /api/v1.0/chat/rooms/{id}/messages/      # Get messages
POST /api/v1.0/chat/rooms/{id}/messages/      # Send message (HTTP)
PATCH /api/v1.0/chat/messages/{id}/mark_read/ # Mark as read

WS   /ws/chat/{roomId}/?token={jwt}           # Real-time WebSocket
```

## WebSocket Events

### Sending Events

```dart
// Send message
{'type': 'chat_message', 'message': 'Hello!'}

// Typing indicator
{'type': 'typing', 'is_typing': true}

// Mark as read
{'type': 'mark_read', 'message_id': 123}
```

### Receiving Events

```dart
// New message
{
  'type': 'chat_message',
  'message': {
    'id': 123,
    'content': 'Hello!',
    'sender': {...},
    'created_at': '2025-11-21T10:30:00Z'
  }
}

// Typing indicator
{
  'type': 'typing',
  'user_id': 5,
  'is_typing': true
}

// Read receipt
{
  'type': 'message_read',
  'message_id': 123,
  'read_by': 1
}
```

## Testing

### Test Real-Time Chat

1. **Login** on two devices/emulators with different accounts
2. **Match** with each other (swipe right)
3. **Open Messages** tab on both devices
4. **Start chatting** - messages appear instantly!
5. **Type** - see typing indicator on other device
6. **Read messages** - see checkmarks turn green

### Test HTTP Fallback

1. **Disconnect** from internet briefly
2. **Send message** - it queues
3. **Reconnect** - message sends via HTTP
4. **WebSocket** reconnects automatically

## Customization

### Change Message Bubble Colors

Edit `chat_detail_page.dart`:

```dart
// Sent messages (currently black gradient)
gradient: const LinearGradient(
  colors: [Color(0xFF000000), Color(0xFF2a2a2a)],
),

// Received messages (currently white)
color: Colors.white,
```

### Change Typing Indicator

Edit `chat_detail_page.dart` in `_buildTypingIndicator()`:

```dart
// Customize dots color, size, animation
Container(
  width: 4,
  height: 4,
  decoration: BoxDecoration(
    color: Colors.grey[400], // Change color here
    shape: BoxShape.circle,
  ),
)
```

### Change Time Format

The system uses `timeago` package. To customize:

```dart
// In chat_page.dart or chat_detail_page.dart
timeago.format(
  DateTime.parse(message.createdAt),
  locale: 'en_short', // Change locale here
)

// Available locales: en, en_short, es, fr, de, etc.
```

## Troubleshooting

### "No chat rooms" showing

**Solution:** Make sure you have matches. Chat rooms are created when two users match.

### Messages not sending

**Check:**
1. Backend is running
2. JWT token is valid
3. WebSocket URL is correct
4. Check console for errors

### WebSocket not connecting

**Check:**
1. Backend WebSocket server is running
2. URL format: `ws://localhost:8000/ws/chat/{roomId}/?token={jwt}`
3. JWT token is included in URL
4. CORS settings allow WebSocket connections

### Typing indicator not working

**Check:**
1. WebSocket is connected (check console)
2. Backend handles `typing` event type
3. Both users are in the same chat room

## Performance Tips

### Message Pagination

Messages load 50 at a time. Adjust in `chat_detail_provider.dart`:

```dart
final result = await _repository.getMessages(
  roomId: roomId,
  page: page,
  pageSize: 50, // Change this number
);
```

### WebSocket Reconnection

WebSocket auto-reconnects on disconnect. To customize:

```dart
// In websocket_service.dart
// Add retry logic, exponential backoff, etc.
```

### Message Caching

For offline support, consider adding local caching:

```dart
// Use Hive or Isar to cache messages locally
// Load from cache first, then sync with server
```

## Next Features to Add

1. **Image Sharing** - Send photos in chat
2. **Voice Messages** - Record and send audio
3. **Message Reactions** - Add emoji reactions
4. **Push Notifications** - Notify when app is closed
5. **Unread Badge** - Show count on tab bar
6. **Message Search** - Search within conversation
7. **Chat Backup** - Export chat history
8. **Block/Report** - Implement block and report functionality

## Support

For issues or questions:
1. Check `CHAT_REAL_TIME_INTEGRATION_COMPLETE.md` for detailed documentation
2. Review `API_DATA_FORMATS.md` for API specifications
3. Check console logs for error messages
4. Verify backend is running and accessible

---

**Your chat system is now fully integrated with real-time WebSocket functionality!** 🎉
