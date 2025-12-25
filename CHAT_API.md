# Chat API Documentation

## Overview

Complete API documentation for the WhatsApp-style chat system with real-time messaging, typing indicators, and message status tracking.

## 🔗 Base URL

```
https://your-domain.com/api/v1.0/chat/
```

## 🔐 Authentication

All API endpoints require JWT authentication:

```http
Authorization: Bearer <your_jwt_token>
```

## 📡 WebSocket Connection

### Connection URL

```
wss://your-domain.com/ws/chat/{room_id}/?token={jwt_token}
```

### Connection Parameters

- `room_id`: Integer - The chat room ID
- `token`: String - JWT authentication token

## 🏠 REST API Endpoints

### 1. List Chat Rooms

Get all chat rooms for the authenticated user.

```http
GET /api/v1.0/chat/rooms/
```

**Response:**

```json
{
  "count": 2,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "participant1": {
        "id": 1,
        "username": "john_doe",
        "display_name": "John Doe",
        "imageUrls": ["https://example.com/avatar1.jpg"],
        "is_online": true,
        "last_seen": "2024-12-25T10:30:00Z"
      },
      "participant2": {
        "id": 2,
        "username": "jane_smith",
        "display_name": "Jane Smith",
        "imageUrls": ["https://example.com/avatar2.jpg"],
        "is_online": false,
        "last_seen": "2024-12-25T09:15:00Z"
      },
      "other_participant": {
        "id": 2,
        "username": "jane_smith",
        "display_name": "Jane Smith",
        "imageUrls": ["https://example.com/avatar2.jpg"],
        "is_online": false,
        "last_seen": "2024-12-25T09:15:00Z"
      },
      "match": 123,
      "last_message": {
        "id": 456,
        "content": "Hey, how are you?",
        "sender_id": 2,
        "status": "read",
        "created_at": "2024-12-25T10:25:00Z"
      },
      "unread_count": 0,
      "typing_users": [],
      "created_at": "2024-12-25T08:00:00Z"
    }
  ]
}
```

### 2. Get Chat Room Details

Get details of a specific chat room.

```http
GET /api/v1.0/chat/rooms/{room_id}/
```

**Response:**

```json
{
  "id": 1,
  "participant1": {
    "id": 1,
    "username": "john_doe",
    "display_name": "John Doe",
    "imageUrls": ["https://example.com/avatar1.jpg"],
    "is_online": true,
    "last_seen": "2024-12-25T10:30:00Z"
  },
  "participant2": {
    "id": 2,
    "username": "jane_smith",
    "display_name": "Jane Smith",
    "imageUrls": ["https://example.com/avatar2.jpg"],
    "is_online": false,
    "last_seen": "2024-12-25T09:15:00Z"
  },
  "other_participant": {
    "id": 2,
    "username": "jane_smith",
    "display_name": "Jane Smith",
    "imageUrls": ["https://example.com/avatar2.jpg"],
    "is_online": false,
    "last_seen": "2024-12-25T09:15:00Z"
  },
  "match": 123,
  "last_message": {
    "id": 456,
    "content": "Hey, how are you?",
    "sender_id": 2,
    "status": "read",
    "created_at": "2024-12-25T10:25:00Z"
  },
  "unread_count": 0,
  "typing_users": [
    {
      "id": 2,
      "username": "jane_smith",
      "display_name": "Jane Smith"
    }
  ],
  "created_at": "2024-12-25T08:00:00Z"
}
```

### 3. Get Messages in Room

Get paginated messages for a specific chat room.

```http
GET /api/v1.0/chat/rooms/{room_id}/messages/?page=1
```

**Query Parameters:**

- `page`: Integer (optional) - Page number for pagination

**Response:**

```json
{
  "count": 50,
  "next": "http://example.com/api/v1.0/chat/rooms/1/messages/?page=2",
  "previous": null,
  "results": [
    {
      "id": 456,
      "room": 1,
      "sender": {
        "id": 2,
        "username": "jane_smith",
        "display_name": "Jane Smith",
        "imageUrls": ["https://example.com/avatar2.jpg"],
        "is_online": false,
        "last_seen": "2024-12-25T09:15:00Z"
      },
      "content": "Hey, how are you?",
      "status": "read",
      "status_display": "Read",
      "sent_at": "2024-12-25T10:25:01Z",
      "delivered_at": "2024-12-25T10:25:02Z",
      "read_at": "2024-12-25T10:26:00Z",
      "is_read": true,
      "created_at": "2024-12-25T10:25:00Z",
      "updated_at": "2024-12-25T10:26:00Z"
    }
  ]
}
```

### 4. Send Message (HTTP - Optional)

Send a message via HTTP (WebSocket is preferred for real-time).

```http
POST /api/v1.0/chat/messages/
```

**Request Body:**

```json
{
  "room": 1,
  "content": "Hello there!"
}
```

**Response:**

```json
{
  "id": 457,
  "room": 1,
  "sender": {
    "id": 1,
    "username": "john_doe",
    "display_name": "John Doe",
    "imageUrls": ["https://example.com/avatar1.jpg"],
    "is_online": true,
    "last_seen": "2024-12-25T10:30:00Z"
  },
  "content": "Hello there!",
  "status": "sending",
  "status_display": "Sending",
  "sent_at": null,
  "delivered_at": null,
  "read_at": null,
  "is_read": false,
  "created_at": "2024-12-25T10:30:00Z",
  "updated_at": "2024-12-25T10:30:00Z"
}
```

### 5. Connection Statistics

Get connection and chat statistics.

```http
GET /api/v1.0/chat/stats/
```

**Response:**

```json
{
  "user_id": 1,
  "total_rooms": 3,
  "active_rooms_today": 2,
  "recent_messages_24h": 15,
  "channel_layer_status": "available",
  "timestamp": "2024-12-25T10:30:00Z",
  "connection_settings": {
    "heartbeat_interval": 30,
    "connection_timeout": 14400,
    "ping_timeout": 10,
    "max_reconnect_attempts": 5
  }
}
```

### 6. Room Health Check

Check the health of a specific chat room's connections.

```http
GET /api/v1.0/chat/rooms/{room_id}/health/
```

**Response:**

```json
{
  "room_id": 1,
  "group_name": "chat_1",
  "health_check_sent": true,
  "recent_messages_count": 5,
  "timestamp": "2024-12-25T10:30:00Z"
}
```

### 7. Broadcast Health Check

Send health check to all user's active chat rooms.

```http
POST /api/v1.0/chat/health-check/
```

**Response:**

```json
{
  "health_checks_sent": 3,
  "total_rooms": 3,
  "timestamp": "2024-12-25T10:30:00Z"
}
```

## 📡 WebSocket Protocol

### Message Types

#### 1. Client → Server Messages

##### Send Message

```json
{
  "type": "message",
  "content": "Hello, world!",
  "temp_id": "temp_1703419800123",
  "timestamp": "2024-12-25T10:30:00Z"
}
```

##### Typing Indicators

```json
{
  "type": "typing_on",
  "timestamp": "2024-12-25T10:30:00Z"
}
```

```json
{
  "type": "typing_off",
  "timestamp": "2024-12-25T10:30:00Z"
}
```

##### Message Status Updates

```json
{
  "type": "message_read",
  "message_id": 456,
  "timestamp": "2024-12-25T10:30:00Z"
}
```

```json
{
  "type": "message_delivered",
  "message_id": 456,
  "timestamp": "2024-12-25T10:30:00Z"
}
```

##### Heartbeat

```json
{
  "type": "ping",
  "timestamp": "2024-12-25T10:30:00Z"
}
```


```json
{
  "type": "pong",
  "timestamp": "2024-12-25T10:30:00Z",
  "client_time": "2024-12-25T10:30:01Z"
}
```

##### Connection Check

```json
{
  "type": "connection_check",
  "timestamp": "2024-12-25T10:30:00Z"
}
```

#### 2. Server → Client Messages

##### Connection Established

```json
{
  "type": "connection_established",
  "room_id": 1,
  "user_id": 123,
  "timestamp": "2024-12-25T10:30:00Z",
  "heartbeat_interval": 30,
  "connection_timeout": 14400
}
```

##### New Message

```json
{
  "type": "message",
  "message": {
    "id": 456,
    "content": "Hello, world!",
    "sender_id": 123,
    "sender_username": "john_doe",
    "status": "sent",
    "created_at": "2024-12-25T10:30:00Z",
    "room_id": 1
  },
  "delivery_id": "msg_456_1703419800.123"
}
```

##### Message Status Update

```json
{
  "type": "message_status_update",
  "message_id": 456,
  "status": "read",
  "timestamp": "2024-12-25T10:30:00Z",
  "updated_by": 789
}
```

##### Typing Indicator

```json
{
  "type": "typing",
  "user_id": 789,
  "username": "jane_smith",
  "is_typing": true,
  "timestamp": "2024-12-25T10:30:00Z"
}
```

##### User Status Change

```json
{
  "type": "user_status_change",
  "user_id": 789,
  "username": "jane_smith",
  "is_online": true,
  "last_seen": "2024-12-25T10:30:00Z"
}
```

##### Heartbeat

```json
{
  "type": "ping",
  "timestamp": "2024-12-25T10:30:00Z",
  "sequence": 1
}
```

```json
{
  "type": "pong",
  "timestamp": "2024-12-25T10:30:00Z",
  "server_time": "2024-12-25T10:30:01Z"
}
```

##### Connection Status

```json
{
  "type": "connection_status",
  "status": "healthy",
  "duration_seconds": 3600,
  "last_activity": "2024-12-25T10:29:00Z",
  "timestamp": "2024-12-25T10:30:00Z"
}
```

##### Health Check Response

```json
{
  "type": "health_check_response",
  "room_id": 1,
  "user_id": 123,
  "connection_duration": 3600,
  "last_activity": "2024-12-25T10:29:00Z",
  "is_alive": true,
  "timestamp": "2024-12-25T10:30:00Z"
}
```

##### Reconnection Suggestion

```json
{
  "type": "reconnect_suggested",
  "reason": "ping_timeout",
  "attempts": 3,
  "max_attempts": 5
}
```

##### Error Message

```json
{
  "type": "error",
  "message": "Message too long (max 1000 characters)",
  "timestamp": "2024-12-25T10:30:00Z"
}
```

## 📊 Message Status Flow

### Status Progression

1. **sending** → Message created locally, being sent to server
2. **sent** → Message received by server
3. **delivered** → Message delivered to recipient's device
4. **read** → Message read by recipient
5. **failed** → Message failed to send

### Status Icons (WhatsApp Style)

- **sending**: 🕐 (Clock)
- **sent**: ✓ (Single check, gray)
- **delivered**: ✓✓ (Double check, gray)
- **read**: ✓✓ (Double check, blue)
- **failed**: ❌ (Red X)

## 🔄 Real-time Features Implementation

### 1. Typing Indicators

**Start Typing:**

```javascript
// Send when user starts typing
chatClient.startTyping();

// Auto-stop after 3 seconds of inactivity
setTimeout(() => chatClient.stopTyping(), 3000);
```

**Handle Typing Events:**

```javascript
chatClient.onTypingIndicator = (data) => {
  if (data.isTyping) {
    showTypingIndicator(data.username);
  } else {
    hideTypingIndicator(data.username);
  }
};
```

### 2. Message Status Tracking

**Send Message with Status Tracking:**

```javascript
// Send message
const tempId = `temp_${Date.now()}`;
chatClient.sendMessage("Hello!", tempId);

// Handle status updates
chatClient.onMessageStatusUpdate = (messageId, status) => {
  updateMessageIcon(messageId, getStatusIcon(status));
};
```

**Auto-mark Messages as Read:**

```javascript
// When message comes into view
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      const messageId = entry.target.dataset.messageId;
      chatClient.sendMessageRead(messageId);
    }
  });
});
```

### 3. Online Status Tracking

**Handle User Status:**

```javascript
chatClient.onUserStatusChange = (data) => {
  updateUserStatus(data.user_id, {
    isOnline: data.is_online,
    lastSeen: data.last_seen,
  });
};
```

## 🚨 Error Handling

### Connection Errors

```javascript
chatClient.onError = (message, error) => {
  console.error("Chat error:", message, error);

  switch (message) {
    case "Connection failed":
      showConnectionError();
      break;
    case "Message sending failed":
      markMessageAsFailed();
      break;
    case "Authentication failed":
      redirectToLogin();
      break;
  }
};
```

### Reconnection Handling

```javascript
chatClient.onConnectionChange = (status, code) => {
  switch (status) {
    case "connecting":
      showConnectingIndicator();
      break;
    case "connected":
      hideConnectingIndicator();
      break;
    case "disconnected":
      if (code !== 1000) {
        // Not a clean disconnect
        showReconnectingMessage();
      }
      break;
  }
};
```

## 🔧 Configuration Options

### WebSocket Client Options

```javascript
const options = {
  heartbeatInterval: 30000, // 30 seconds
  reconnectInterval: 5000, // 5 seconds
  maxReconnectAttempts: 10, // 10 attempts
  typingTimeout: 3000, // 3 seconds
  messageTimeout: 30000, // 30 seconds
  connectionTimeout: 10000, // 10 seconds
};
```

### Server Configuration

```python
# In Django settings.py
WEBSOCKET_SETTINGS = {
    'HEARTBEAT_INTERVAL': 30,
    'CONNECTION_TIMEOUT': 14400,  # 4 hours
    'PING_TIMEOUT': 10,
    'MAX_RECONNECT_ATTEMPTS': 5,
    'MESSAGE_SIZE_LIMIT': 1000,
}
```

## 📱 Mobile Considerations

### Background Connection Handling

```javascript
// Handle app going to background
document.addEventListener("visibilitychange", () => {
  if (document.hidden) {
    // App went to background
    chatClient.pauseHeartbeat();
  } else {
    // App came to foreground
    chatClient.resumeHeartbeat();
    chatClient.checkConnection();
  }
});
```

### Network Change Handling

```javascript
// Handle network changes
window.addEventListener("online", () => {
  if (!chatClient.isConnected) {
    chatClient.connect();
  }
});

window.addEventListener("offline", () => {
  showOfflineMessage();
});
```

## 🧪 Testing

### Connection Testing

```bash
# Test WebSocket connection
python manage.py test_redis

# Monitor connections
python manage.py monitor_connections --interval 60

# Load test
python chat/test_long_connection.py wss://domain.com/ws/chat/1/ token stress 30
```

### API Testing

```bash
# Test REST endpoints
curl -H "Authorization: Bearer $TOKEN" \
     https://domain.com/api/v1.0/chat/rooms/

# Test health check
curl -X POST -H "Authorization: Bearer $TOKEN" \
     https://domain.com/api/v1.0/chat/health-check/
```

This documentation provides everything needed to implement a complete WhatsApp-style chat system with real-time features and no additional HTTP requests for real-time functionality!
