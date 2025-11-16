# API Data Formats - JSON Request/Response Examples

This document shows the exact JSON format for all API endpoints based on the Django backend structure.

---

## Authentication

### POST `/auth/jwt/create/` - Login
**Request:**
```json
{
  "email": "user@university.edu",
  "password": "securePassword123"
}
```

**Response (200 OK):**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### POST `/auth/jwt/refresh/` - Refresh Token
**Request:**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response (200 OK):**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### POST `/auth/users/` - Register
**Request:**
```json
{
  "username": "john_doe",
  "email": "john@university.edu",
  "password": "securePassword123",
  "university": 1,
  "gender": "male",
  "preferred_genders": ["female"],
  "intent": "dating"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@university.edu",
  "university": {
    "id": 1,
    "name": "Stanford University",
    "slug": "stanford-university",
    "logo": "http://api.example.com/media/universities/logos/stanford.png"
  },
  "gender": "male",
  "preferred_genders": ["female"],
  "intent": "dating",
  "is_private": false,
  "anon_handle": "abcd1234",
  "show_real_name_on_match": true,
  "subscription_active": false,
  "remaining_profile_views": 10,
  "display_name": "John Doe"
}
```

---

## Universities

### GET `/api/universities/` - List Universities (No Authentication Required)
**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Stanford University",
    "slug": "stanford-university",
    "logo": "http://api.example.com/media/universities/logos/stanford.png"
  },
  {
    "id": 2,
    "name": "Harvard University",
    "slug": "harvard-university",
    "logo": "http://api.example.com/media/universities/logos/harvard.png"
  },
  {
    "id": 3,
    "name": "MIT",
    "slug": "mit",
    "logo": "http://api.example.com/media/universities/logos/mit.png"
  }
]
```

### GET `/api/universities/{slug}/` - Get University by Slug (No Authentication Required)
**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Stanford University",
  "slug": "stanford-university",
  "logo": "http://api.example.com/media/universities/logos/stanford.png"
}
```

---

## Users

### GET `/api/users/me/` - Get Current User
**Headers:**
```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc...
```

**Response (200 OK):**
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@university.edu",
  "university": {
    "id": 1,
    "name": "Stanford University",
    "slug": "stanford-university",
    "logo": "http://api.example.com/media/universities/logos/stanford.png"
  },
  "gender": "male",
  "preferred_genders": ["female"],
  "intent": "dating",
  "is_private": false,
  "anon_handle": null,
  "show_real_name_on_match": true,
  "subscription_active": false,
  "remaining_profile_views": 10,
  "quota_reset_at": "2025-11-22T00:00:00Z",
  "display_name": "John Doe"
}
```

### PATCH `/api/users/me/` - Update User
**Request:**
```json
{
  "is_private": true,
  "anon_handle": "mysterious_student",
  "show_real_name_on_match": false,
  "preferred_genders": ["female", "non-binary"]
}
```

**Response (200 OK):**
```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@university.edu",
  "university": {
    "id": 1,
    "name": "Stanford University",
    "slug": "stanford-university",
    "logo": "http://api.example.com/media/universities/logos/stanford.png"
  },
  "gender": "male",
  "preferred_genders": ["female", "non-binary"],
  "intent": "dating",
  "is_private": true,
  "anon_handle": "mysterious_student",
  "show_real_name_on_match": false,
  "subscription_active": false,
  "remaining_profile_views": 10,
  "display_name": "mysterious_student"
}
```

---

## Profiles

### GET `/api/profiles/` - List Profiles (Discovery)
**Query Parameters:**
```
?gender=female&intent=dating&university=1&page=1
```

**Response (200 OK):**
```json
{
  "count": 45,
  "next": "http://api.example.com/api/profiles/?page=2",
  "previous": null,
  "results": [
    {
      "id": 5,
      "user": 5,
      "username": "jane_smith",
      "display_name": "Jane S.",
      "bio": "Love hiking and coffee ☕",
      "age": 21,
      "gender": "female",
      "intent": "dating",
      "university": 1,
      "university_name": "Stanford University",
      "major": "Computer Science",
      "graduation_year": 2026,
      "interests": ["hiking", "coffee", "coding"],
      "profile_photo": "http://api.example.com/media/profiles/jane_photo.jpg",
      "is_private": false,
      "created_at": "2025-11-10T14:30:00Z"
    }
  ]
}
```

### GET `/api/profiles/{id}/` - Get Profile Detail
**Response (200 OK):**
```json
{
  "id": 5,
  "user": 5,
  "username": "jane_smith",
  "display_name": "Jane S.",
  "bio": "Love hiking and coffee ☕",
  "age": 21,
  "gender": "female",
  "intent": "dating",
  "university": 1,
  "university_name": "Stanford University",
  "major": "Computer Science",
  "graduation_year": 2026,
  "interests": ["hiking", "coffee", "coding"],
  "profile_photo": "http://api.example.com/media/profiles/jane_photo.jpg",
  "gallery_photos": [
    {
      "id": 1,
      "image": "http://api.example.com/media/gallery/photo1.jpg",
      "order": 1
    },
    {
      "id": 2,
      "image": "http://api.example.com/media/gallery/photo2.jpg",
      "order": 2
    }
  ],
  "is_private": false,
  "created_at": "2025-11-10T14:30:00Z",
  "updated_at": "2025-11-14T10:20:00Z"
}
```

### POST `/api/profiles/` - Create Profile
**Request (multipart/form-data):**
```json
{
  "bio": "Love hiking and coffee ☕",
  "age": 21,
  "major": "Computer Science",
  "graduation_year": 2026,
  "interests": ["hiking", "coffee", "coding"],
  "profile_photo": "<file>"
}
```

**Response (201 Created):**
```json
{
  "id": 5,
  "user": 5,
  "username": "jane_smith",
  "display_name": "Jane S.",
  "bio": "Love hiking and coffee ☕",
  "age": 21,
  "gender": "female",
  "intent": "dating",
  "university": 1,
  "major": "Computer Science",
  "graduation_year": 2026,
  "interests": ["hiking", "coffee", "coding"],
  "profile_photo": "http://api.example.com/media/profiles/jane_photo.jpg",
  "is_private": false,
  "created_at": "2025-11-15T14:30:00Z"
}
```

### POST `/api/profiles/{id}/like/` - Like a Profile
**Response (201 Created) - No Match:**
```json
{
  "detail": "Profile liked successfully.",
  "matched": false
}
```

**Response (201 Created) - Match Created:**
```json
{
  "detail": "It's a match!",
  "match_id": 12,
  "matched": true
}
```

**Error (400 Bad Request):**
```json
{
  "detail": "You have already liked this profile."
}
```

---

## Gallery

### GET `/api/gallery/` - List User's Gallery Photos
**Response (200 OK):**
```json
[
  {
    "id": 1,
    "user": 1,
    "image": "http://api.example.com/media/gallery/photo1.jpg",
    "order": 1,
    "uploaded_at": "2025-11-10T14:30:00Z"
  },
  {
    "id": 2,
    "user": 1,
    "image": "http://api.example.com/media/gallery/photo2.jpg",
    "order": 2,
    "uploaded_at": "2025-11-11T09:15:00Z"
  }
]
```

### POST `/api/gallery/` - Upload Photo
**Request (multipart/form-data):**
```
image: <file>
order: 1
```

**Response (201 Created):**
```json
{
  "id": 3,
  "user": 1,
  "image": "http://api.example.com/media/gallery/photo3.jpg",
  "order": 1,
  "uploaded_at": "2025-11-15T16:45:00Z"
}
```

### DELETE `/api/gallery/{id}/` - Delete Photo
**Response (204 No Content)**

---

## Interactions

### GET `/api/matches/` - List Matches
**Response (200 OK):**
```json
[
  {
    "id": 12,
    "user1": 1,
    "user2": 5,
    "other_user": {
      "id": 5,
      "username": "jane_smith",
      "display_name": "Jane S.",
      "profile_photo": "http://api.example.com/media/profiles/jane_photo.jpg"
    },
    "created_at": "2025-11-14T18:30:00Z"
  },
  {
    "id": 15,
    "user1": 1,
    "user2": 8,
    "other_user": {
      "id": 8,
      "username": "sarah_jones",
      "display_name": "Sarah J.",
      "profile_photo": "http://api.example.com/media/profiles/sarah_photo.jpg"
    },
    "created_at": "2025-11-13T12:15:00Z"
  }
]
```

### GET `/api/likes/` - List Likes (Sent/Received)
**Query Parameters:**
```
?type=sent  or  ?type=received
```

**Response (200 OK):**
```json
[
  {
    "id": 23,
    "liker": 1,
    "liked": 7,
    "like_type": "profile",
    "profile_info": {
      "id": 7,
      "username": "emily_wilson",
      "display_name": "Emily W.",
      "profile_photo": "http://api.example.com/media/profiles/emily_photo.jpg"
    },
    "created_at": "2025-11-15T10:20:00Z"
  }
]
```

### POST `/api/likes/` - Create Like
**Request:**
```json
{
  "liked": 7,
  "like_type": "profile"
}
```

**Response (201 Created):**
```json
{
  "id": 23,
  "liker": 1,
  "liked": 7,
  "like_type": "profile",
  "created_at": "2025-11-15T10:20:00Z"
}
```

### GET `/api/profile-views/` - List Profile Views
**Response (200 OK):**
```json
[
  {
    "id": 45,
    "viewer": 1,
    "viewed": 9,
    "viewed_profile": {
      "id": 9,
      "username": "alex_brown",
      "display_name": "Alex B.",
      "profile_photo": "http://api.example.com/media/profiles/alex_photo.jpg"
    },
    "viewed_at": "2025-11-15T09:30:00Z"
  }
]
```

### POST `/api/profile-views/` - Record Profile View
**Request:**
```json
{
  "viewed": 9
}
```

**Response (201 Created):**
```json
{
  "id": 45,
  "viewer": 1,
  "viewed": 9,
  "viewed_at": "2025-11-15T09:30:00Z"
}
```

---

## Chat

### GET `/api/chat/rooms/` - List Chat Rooms
**Response (200 OK):**
```json
[
  {
    "id": 3,
    "participant1": 1,
    "participant2": 5,
    "match": 12,
    "other_participant": {
      "id": 5,
      "username": "jane_smith",
      "display_name": "Jane S.",
      "profile_photo": "http://api.example.com/media/profiles/jane_photo.jpg"
    },
    "last_message": {
      "id": 156,
      "content": "Hey! How are you?",
      "sender": 5,
      "created_at": "2025-11-15T14:20:00Z",
      "is_read": false
    },
    "unread_count": 2,
    "created_at": "2025-11-14T18:30:00Z"
  }
]
```

### GET `/api/chat/rooms/{id}/` - Get Chat Room Detail
**Response (200 OK):**
```json
{
  "id": 3,
  "participant1": 1,
  "participant2": 5,
  "match": 12,
  "other_participant": {
    "id": 5,
    "username": "jane_smith",
    "display_name": "Jane S.",
    "profile_photo": "http://api.example.com/media/profiles/jane_photo.jpg",
    "is_online": true
  },
  "created_at": "2025-11-14T18:30:00Z"
}
```

### GET `/api/chat/rooms/{room_id}/messages/` - List Messages
**Query Parameters:**
```
?page=1&page_size=50
```

**Response (200 OK):**
```json
{
  "count": 156,
  "next": "http://api.example.com/api/chat/rooms/3/messages/?page=2",
  "previous": null,
  "results": [
    {
      "id": 156,
      "room": 3,
      "sender": 5,
      "sender_info": {
        "id": 5,
        "username": "jane_smith",
        "display_name": "Jane S."
      },
      "content": "Hey! How are you?",
      "is_read": false,
      "created_at": "2025-11-15T14:20:00Z",
      "updated_at": "2025-11-15T14:20:00Z"
    },
    {
      "id": 155,
      "room": 3,
      "sender": 1,
      "sender_info": {
        "id": 1,
        "username": "john_doe",
        "display_name": "John D."
      },
      "content": "Hi there!",
      "is_read": true,
      "created_at": "2025-11-15T14:15:00Z",
      "updated_at": "2025-11-15T14:16:00Z"
    }
  ]
}
```

### POST `/api/chat/rooms/{room_id}/messages/` - Send Message (HTTP)
**Request:**
```json
{
  "content": "Hey! How are you?"
}
```

**Response (201 Created):**
```json
{
  "id": 156,
  "room": 3,
  "sender": 1,
  "content": "Hey! How are you?",
  "is_read": false,
  "created_at": "2025-11-15T14:20:00Z",
  "updated_at": "2025-11-15T14:20:00Z"
}
```

### PATCH `/api/chat/messages/{id}/mark_read/` - Mark Message as Read
**Response (200 OK):**
```json
{
  "id": 156,
  "room": 3,
  "sender": 5,
  "content": "Hey! How are you?",
  "is_read": true,
  "created_at": "2025-11-15T14:20:00Z",
  "updated_at": "2025-11-15T14:25:00Z"
}
```

---

## WebSocket - Real-time Chat

### Connection
**URL:** `wss://api.example.com/ws/chat/{room_id}/`

**Query Parameter:**
```
?token=eyJ0eXAiOiJKV1QiLCJhbGc...
```

### Send Message (Client → Server)
```json
{
  "type": "chat_message",
  "message": "Hello from WebSocket!"
}
```

### Receive Message (Server → Client)
```json
{
  "type": "chat_message",
  "message": {
    "id": 157,
    "room": 3,
    "sender": 5,
    "sender_info": {
      "id": 5,
      "username": "jane_smith",
      "display_name": "Jane S."
    },
    "content": "Hello from WebSocket!",
    "is_read": false,
    "created_at": "2025-11-15T14:30:00Z"
  }
}
```

### Typing Indicator (Client → Server)
```json
{
  "type": "typing",
  "is_typing": true
}
```

### Typing Indicator (Server → Client)
```json
{
  "type": "typing",
  "user_id": 5,
  "is_typing": true
}
```

### Read Receipt (Client → Server)
```json
{
  "type": "mark_read",
  "message_id": 156
}
```

### Read Receipt (Server → Client)
```json
{
  "type": "message_read",
  "message_id": 156,
  "read_by": 1
}
```

---

## Payments

### GET `/api/payments/subscriptions/` - List Subscriptions
**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Premium Monthly",
    "description": "Unlimited profile views and advanced filters",
    "price": "9.99",
    "currency": "USD",
    "duration_days": 30,
    "features": {
      "unlimited_views": true,
      "advanced_filters": true,
      "priority_support": true
    },
    "is_active": true,
    "created_at": "2025-11-01T00:00:00Z"
  }
]
```

### POST `/api/payments/transactions/` - Create Transaction
**Request:**
```json
{
  "subscription": 1,
  "amount": "9.99",
  "currency": "USD",
  "payment_method": "stripe"
}
```

**Response (201 Created):**
```json
{
  "id": 45,
  "user": 1,
  "subscription": 1,
  "amount": "9.99",
  "currency": "USD",
  "payment_method": "stripe",
  "status": "pending",
  "reference": "TXN-20251115-45",
  "external_reference": null,
  "reason_for_failure": null,
  "initiated_at": "2025-11-15T15:00:00Z",
  "completed_at": null,
  "created_at": "2025-11-15T15:00:00Z",
  "updated_at": "2025-11-15T15:00:00Z"
}
```

### GET `/api/payments/transactions/{id}/` - Get Transaction Status
**Response (200 OK):**
```json
{
  "id": 45,
  "user": 1,
  "subscription": 1,
  "amount": "9.99",
  "currency": "USD",
  "payment_method": "stripe",
  "status": "completed",
  "reference": "TXN-20251115-45",
  "external_reference": "pi_3AbCdEfGhIjKlMnO",
  "reason_for_failure": null,
  "initiated_at": "2025-11-15T15:00:00Z",
  "completed_at": "2025-11-15T15:01:30Z",
  "created_at": "2025-11-15T15:00:00Z",
  "updated_at": "2025-11-15T15:01:30Z"
}
```

---

## Error Responses

### 400 Bad Request
```json
{
  "detail": "Invalid input data",
  "errors": {
    "email": ["This field is required."],
    "age": ["Ensure this value is greater than or equal to 18."]
  }
}
```

### 401 Unauthorized
```json
{
  "detail": "Authentication credentials were not provided."
}
```

or

```json
{
  "detail": "Given token not valid for any token type",
  "code": "token_not_valid"
}
```

### 403 Forbidden
```json
{
  "detail": "You can only chat with matched users."
}
```

### 404 Not Found
```json
{
  "detail": "Not found."
}
```

### 429 Too Many Requests
```json
{
  "detail": "You have reached your weekly profile view limit. Upgrade to premium for unlimited views."
}
```

### 500 Internal Server Error
```json
{
  "detail": "An error occurred while processing your request."
}
```

---

## Notes

1. **Authentication**: All endpoints except `/auth/*` require JWT token in header:
   ```
   Authorization: Bearer <access_token>
   ```

2. **Pagination**: List endpoints use cursor/page pagination with `count`, `next`, `previous` fields

3. **Timestamps**: All timestamps are in ISO 8601 format (UTC): `2025-11-15T14:30:00Z`

4. **File Uploads**: Use `multipart/form-data` content type for image uploads

5. **WebSocket**: Requires JWT token as query parameter for authentication

6. **Gender Values**: `male`, `female`, `other`

7. **Intent Values**: `relationship`, `dating`, `friends`

8. **Payment Status**: `pending`, `completed`, `failed`, `refunded`

9. **Universities Endpoint**: `/api/universities/` is publicly accessible without authentication
