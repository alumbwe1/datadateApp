# DataDate - API Documentation Index

## 📚 Complete API Documentation

This document serves as the central index for all API-related documentation in the DataDate application.

## 🔗 API Documentation Files

### Core API Documentation
- **[CHAT_API.md](CHAT_API.md)** - Complete WhatsApp-style chat system API
- **[API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md)** - Step-by-step API integration guide
- **[API_IMPLEMENTATION_SUMMARY.md](API_IMPLEMENTATION_SUMMARY.md)** - Implementation overview
- **[API_QUICK_REFERENCE.md](API_QUICK_REFERENCE.md)** - Quick API reference guide

### Feature-Specific API Documentation
- **[CHAT_DIRECT_HTTP_IMPLEMENTATION.md](CHAT_DIRECT_HTTP_IMPLEMENTATION.md)** - Chat HTTP implementation
- **[API_DATA_FORMATS.md](API_DATA_FORMATS.md)** - Data format specifications
- **[API_OPTIMIZATION_COMPLETE.md](API_OPTIMIZATION_COMPLETE.md)** - Performance optimizations

## 🌐 API Base URLs

### Environment URLs
```
Development:  https://dev-api.datadate.com/api/v1.0/
Staging:      https://staging-api.datadate.com/api/v1.0/
Production:   https://api.datadate.com/api/v1.0/
```

### WebSocket URLs
```
Development:  wss://dev-api.datadate.com/ws/
Staging:      wss://staging-api.datadate.com/ws/
Production:   wss://api.datadate.com/ws/
```

## 🔐 Authentication

### JWT Token Authentication
All API endpoints require JWT authentication unless specified otherwise.

```http
Authorization: Bearer <your_jwt_token>
Content-Type: application/json
```

### Token Management
- **Access Token**: Valid for 15 minutes
- **Refresh Token**: Valid for 7 days
- **Auto-refresh**: Handled automatically by the app

## 📡 API Endpoints Overview

### Authentication Endpoints
```http
POST /auth/login/                    # User login
POST /auth/register/                 # User registration
POST /auth/refresh/                  # Token refresh
POST /auth/logout/                   # User logout
POST /auth/forgot-password/          # Password reset
POST /auth/verify-email/             # Email verification
```

### User Profile Endpoints
```http
GET    /profiles/me/                 # Get current user profile
PUT    /profiles/me/                 # Update current user profile
DELETE /profiles/me/                 # Delete user account
POST   /profiles/upload-photo/       # Upload profile photo
DELETE /profiles/photos/{id}/        # Delete profile photo
```

### University Endpoints
```http
GET /universities/                   # List universities
GET /universities/search/            # Search universities
GET /universities/{id}/              # Get university details
```

### Encounters (Swiping) Endpoints
```http
GET  /encounters/profiles/           # Get profiles to swipe
POST /encounters/like/               # Like a profile
POST /encounters/pass/               # Pass on a profile
POST /encounters/super-like/         # Super like a profile
GET  /encounters/matches/            # Get user matches
POST /encounters/unmatch/            # Unmatch with user
```

### Chat Endpoints
```http
GET    /chat/rooms/                  # List chat rooms
GET    /chat/rooms/{id}/             # Get chat room details
GET    /chat/rooms/{id}/messages/    # Get messages in room
POST   /chat/messages/               # Send message (HTTP)
PUT    /chat/messages/{id}/          # Edit message
DELETE /chat/messages/{id}/          # Delete message
POST   /chat/messages/{id}/read/     # Mark message as read
```

### Likes Management Endpoints
```http
GET /likes/sent/                     # Get sent likes
GET /likes/received/                 # Get received likes
POST /likes/respond/                 # Respond to received like
DELETE /likes/{id}/                  # Remove like
```

### Reels (Video) Endpoints
```http
GET    /reels/                       # Get video reels
POST   /reels/                       # Upload video reel
PUT    /reels/{id}/                  # Update reel
DELETE /reels/{id}/                  # Delete reel
POST   /reels/{id}/like/             # Like a reel
DELETE /reels/{id}/like/             # Unlike a reel
```

### Premium Features Endpoints
```http
GET  /premium/features/              # Get premium features
POST /premium/boost/                 # Boost profile
POST /premium/super-likes/           # Purchase super likes
GET  /premium/subscription/          # Get subscription status
POST /premium/subscribe/             # Subscribe to premium
```

### Reporting & Blocking Endpoints
```http
POST   /reports/                     # Report user
GET    /reports/my-reports/          # Get user's reports
POST   /blocks/                      # Block user
GET    /blocks/                      # Get blocked users
DELETE /blocks/{id}/                 # Unblock user
```

### System Endpoints
```http
GET /system/status/                  # System health check
GET /system/version/                 # App version info
GET /system/maintenance/             # Maintenance status
```

## 🔌 WebSocket Connections

### Chat WebSocket
```
URL: wss://api.datadate.com/ws/chat/{room_id}/?token={jwt_token}
```

#### Message Types
- `message` - New chat message
- `typing_on` - User started typing
- `typing_off` - User stopped typing
- `message_read` - Message marked as read
- `message_delivered` - Message delivered
- `user_status_change` - User online/offline status
- `ping` / `pong` - Connection heartbeat

### Real-time Updates WebSocket
```
URL: wss://api.datadate.com/ws/updates/?token={jwt_token}
```

#### Update Types
- `new_match` - New match notification
- `new_like` - New like received
- `profile_view` - Profile viewed notification
- `system_notification` - System announcements

## 📊 Response Formats

### Standard Success Response
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "message": "Operation successful"
}
```

### Paginated Response
```json
{
  "count": 100,
  "next": "https://api.datadate.com/api/v1.0/endpoint/?page=2",
  "previous": null,
  "results": [
    // Array of items
  ]
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": {
      "field": ["This field is required"]
    }
  }
}
```

## 🚨 Error Codes

### HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `422` - Validation Error
- `429` - Rate Limited
- `500` - Internal Server Error

### Custom Error Codes
```json
{
  "AUTH_REQUIRED": "Authentication required",
  "TOKEN_EXPIRED": "JWT token has expired",
  "INVALID_CREDENTIALS": "Invalid email or password",
  "USER_NOT_FOUND": "User does not exist",
  "PROFILE_INCOMPLETE": "Profile setup not complete",
  "ALREADY_LIKED": "Profile already liked",
  "MATCH_NOT_FOUND": "Match does not exist",
  "MESSAGE_TOO_LONG": "Message exceeds character limit",
  "RATE_LIMITED": "Too many requests",
  "PREMIUM_REQUIRED": "Premium subscription required"
}
```

## 🔄 Rate Limiting

### Rate Limits by Endpoint Type
- **Authentication**: 5 requests per minute
- **Profile Updates**: 10 requests per minute
- **Swiping Actions**: 100 requests per minute
- **Chat Messages**: 60 requests per minute
- **File Uploads**: 5 requests per minute

### Rate Limit Headers
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## 📱 Mobile-Specific Considerations

### Image Upload Optimization
```http
POST /profiles/upload-photo/
Content-Type: multipart/form-data

# Recommended image specs:
# - Format: JPEG, PNG
# - Max size: 5MB
# - Dimensions: 1080x1080 (square)
# - Quality: 85%
```

### Offline Functionality
- Chat messages cached locally
- Profile data cached for 1 hour
- Images cached indefinitely
- Sync on reconnection

### Push Notifications
```http
POST /notifications/register-device/
{
  "device_token": "fcm_token_here",
  "platform": "android|ios",
  "app_version": "1.0.0"
}
```

## 🧪 Testing & Development

### API Testing Tools
- **Postman Collection**: Available in `/docs/postman/`
- **Swagger UI**: Available at `/api/docs/`
- **WebSocket Tester**: Available at `/ws/test/`

### Development Endpoints
```http
# Only available in development environment
GET  /dev/reset-user/                # Reset user data
POST /dev/generate-test-data/        # Generate test data
GET  /dev/logs/                      # View application logs
```

### Mock Data
- Test users available in development
- Sample chat conversations
- Mock university data
- Test video content

## 📋 API Changelog

### Version 1.0.0 (Current)
- Initial API release
- All core features implemented
- WebSocket real-time features
- Premium feature support

### Upcoming Features (v1.1.0)
- Video calling API
- Advanced matching algorithms
- Group chat functionality
- Enhanced reporting system

## 🔧 SDK & Libraries

### Flutter HTTP Client
```dart
// API client configuration
final apiClient = ApiClient(
  baseUrl: Environment.apiUrl,
  timeout: Duration(seconds: 30),
  interceptors: [
    AuthInterceptor(),
    LoggingInterceptor(),
    ErrorInterceptor(),
  ],
);
```

### WebSocket Client
```dart
// WebSocket service
final wsService = WebSocketService(
  baseUrl: Environment.wsUrl,
  reconnectInterval: Duration(seconds: 5),
  maxReconnectAttempts: 10,
);
```

## 📞 Support & Contact

### API Support
- **Documentation Issues**: Create GitHub issue
- **API Bugs**: Report via support portal
- **Feature Requests**: Submit via feedback form

### Response Times
- **Critical Issues**: 2 hours
- **Bug Reports**: 24 hours
- **Feature Requests**: 1 week
- **Documentation Updates**: 48 hours

---

This API documentation index provides comprehensive coverage of all API-related functionality in the DataDate application. For detailed implementation examples and code samples, refer to the specific documentation files linked above.