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

### POST `/auth/google/` - Google OAuth Login

**Request:**

```json
{
  "token": "google_oauth_id_token_here"
}
```

**Response (200 OK):**

```json
{
  "status": "success",
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": 1,
    "email": "user@gmail.com",
    "username": "user",
    "first_name": "John",
    "last_name": "Doe"
  },
  "created": true
}
```

**Response (400 Bad Request):**

```json
{
  "error": "Invalid token"
}
```

### DELETE `/auth/delete/` - Delete Account

**Response (200 OK):**

```json
{
  "message": "User deleted successfully"
}
```

**Response (401 Unauthorized):**

```json
{
  "error": "Authentication required"
}
```

### POST `/auth/fcm-token/` - Update FCM Token for Push Notifications

**Request:**

```json
{
  "fcm_token": "firebase_cloud_messaging_token_here"
}
```

**Response (200 OK):**

```json
{
  "message": "FCM token updated successfully"
}
```

**Response (400 Bad Request):**

```json
{
  "error": "fcm_token is required"
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

### POST `/auth/users/` - Register (Step 1: Create Account)

**Request:**

```json
{
  "username": "john_doe",
  "email": "john@university.edu",
  "password": "securePassword123",
  "re_password": "securePassword123"
}
```

**Response (201 Created):**

```json
{
  "id": 1,
  "username": "john_doe",
  "email": "john@university.edu"
}
```

**Note:** After registration, login to get JWT token, then complete profile setup via `/api/v1.0/profiles/me/`

---

## Universities

### GET `/api/v1.0/profiles/universities/` - List Universities (No Authentication Required)

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

### GET `/api/v1.0/profiles/universities/{slug}/` - Get University by Slug (No Authentication Required)

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

## Profiles

### GET `/api/v1.0/profiles/me/` - Get Current User's Profile

**Response (200 OK):**

```json
{
  "id": 1,
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@university.edu",
    "first_name": "John",
    "last_name": "Doe"
  },
  "university": 1,
  "university_data": {
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
  "bio": "Love hiking and coffee ☕",
  "real_name": "John Doe",
  "course": "Computer Science",
  "date_of_birth": "2003-05-15",
  "age": 21,
  "graduation_year": 2026,
  "interests": ["hiking", "coffee", "coding", "AI"],
  "imageUrls": [
    "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/john_photo1.jpg",
    "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/john_photo2.jpg"
  ],
  "imagePublicIds": [
    "profiles/user1/photo1_abc123",
    "profiles/user1/photo2_def456"
  ],
  "last_active": "2025-11-17T10:30:00Z",
  "created_at": "2025-11-10T14:30:00Z",
  "updated_at": "2025-11-15T09:20:00Z"
}
```

### PATCH `/api/v1.0/profiles/me/` - Update Current User's Profile (Step 2: Complete Profile)

**Request:**

```json
{
  "university": 1,
  "gender": "male",
  "preferred_genders": ["female"],
  "intent": "dating",
  "is_private": false,
  "show_real_name_on_match": true,
  "bio": "Love hiking, coffee, and coding!",
  "real_name": "John Michael Doe",
  "course": "Computer Science & AI",
  "date_of_birth": "2003-05-15",
  "graduation_year": 2026,
  "interests": ["hiking", "coffee", "coding", "AI", "machine learning"]
}
```

**Response (200 OK):**

```json
{
  "id": 1,
  "user": {
    "id": 1,
    "username": "john_doe",
    "email": "john@university.edu",
    "first_name": "John",
    "last_name": "Doe"
  },
  "university": 1,
  "university_data": {
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
  "bio": "Love hiking, coffee, and coding!",
  "real_name": "John Michael Doe",
  "course": "Computer Science & AI",
  "date_of_birth": "2003-05-15",
  "age": 21,
  "graduation_year": 2026,
  "interests": ["hiking", "coffee", "coding", "AI", "machine learning"],
  "imageUrls": [],
  "imagePublicIds": [],
  "last_active": "2025-11-17T10:35:00Z",
  "created_at": "2025-11-10T14:30:00Z",
  "updated_at": "2025-11-17T10:35:00Z"
}
```

### POST `/api/v1.0/profiles/me/photos/` - Add Profile Photos (Step 3: Optional)

**Request (JSON):**

```json
{
  "imageUrls": [
    "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/photo1.jpg",
    "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/photo2.jpg"
  ],
  "imagePublicIds": [
    "profiles/user1/photo1_abc123",
    "profiles/user1/photo2_def456"
  ]
}
```

**Response (200 OK):**

```json
{
  "detail": "Profile photos updated successfully.",
  "profile": {
    "id": 1,
    "imageUrls": [
      "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/photo1.jpg",
      "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/photo2.jpg"
    ],
    "imagePublicIds": [
      "profiles/user1/photo1_abc123",
      "profiles/user1/photo2_def456"
    ]
  }
}
```

**Note:** Maximum 6 photos allowed. POST appends to existing photos, PATCH replaces all photos.

### PATCH `/api/v1.0/profiles/me/photos/` - Replace All Profile Photos

**Request (JSON):**

```json
{
  "imageUrls": [
    "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/new_photo.jpg"
  ],
  "imagePublicIds": [
    "profiles/user1/new_photo_xyz789"
  ]
}
```

**Response (200 OK):**

```json
{
  "detail": "Profile photos updated successfully.",
  "profile": {
    "id": 1,
    "imageUrls": [
      "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/new_photo.jpg"
    ],
    "imagePublicIds": [
      "profiles/user1/new_photo_xyz789"
    ]
  }
}
```

### DELETE `/api/v1.0/profiles/me/delete_photo/` - Delete Specific Photo

**Request (JSON):**

```json
{
  "publicId": "profiles/user1/photo1_abc123"
}
```

**Response (200 OK):**

```json
{
  "detail": "Photo deleted successfully.",
  "imageUrls": [
    "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/photo2.jpg"
  ],
  "imagePublicIds": [
    "profiles/user1/photo2_def456"
  ]
}
```

**Error (400 Bad Request) - Age Validation:**

```json
{
  "date_of_birth": ["You must be at least 18 years old to use this platform."]
}
```

### GET `/api/v1.0/profiles/` - List Profiles (Browse/Discovery)

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
      "display_name": "Jane S.",
      "user": {
        "id": 5,
        "username": "jane_smith",
        "email": "jane@university.edu",
        "first_name": "Jane",
        "last_name": "Smith"
      },
      "university_data": {
        "id": 1,
        "name": "Stanford University",
        "slug": "stanford-university",
        "logo": "http://api.example.com/media/universities/logos/stanford.png"
      },
      "display_bio": "Love hiking and coffee ☕",
      "gender": "female",
      "intent": "dating",
      "age": 21,
      "course": "Computer Science",
      "graduation_year": 2026,
      "interests": ["hiking", "coffee", "reading"],
      "imageUrls": [
        "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/jane_photo1.jpg"
      ],
      "last_active": "2025-11-17T09:15:00Z"
    },
    {
      "id": 8,
      "display_name": "anon_xyz123",
      "user": {
        "id": 8,
        "username": "sarah_jones",
        "email": "sarah@university.edu",
        "first_name": "Sarah",
        "last_name": "Jones"
      },
      "university_data": {
        "id": 1,
        "name": "Stanford University",
        "slug": "stanford-university",
        "logo": "http://api.example.com/media/universities/logos/stanford.png"
      },
      "display_bio": "Profile is private",
      "gender": "female",
      "intent": "dating",
      "age": 22,
      "course": "Biology",
      "graduation_year": 2027,
      "imageUrls": [
        "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/anon_photo.jpg"
      ],
      "last_active": "2025-11-17T08:45:00Z"
    }
  ]
}
```

### GET `/api/v1.0/profiles/{id}/` - Get Profile Detail

**Response (200 OK) - Public Profile:**

```json
{
  "id": 5,
  "display_name": "Jane Smith",
  "user": {
    "id": 5,
    "username": "jane_smith",
    "email": "jane@university.edu",
    "first_name": "Jane",
    "last_name": "Smith"
  },
  "university_data": {
    "id": 1,
    "name": "Stanford University",
    "slug": "stanford-university",
    "logo": "http://api.example.com/media/universities/logos/stanford.png"
  },
  "display_bio": "Love hiking and coffee ☕",
  "gender": "female",
  "intent": "dating",
  "course": "Computer Science",
  "age": 21,
  "graduation_year": 2026,
  "interests": ["hiking", "coffee", "reading"],
  "imageUrls": [
    "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/jane_photo1.jpg",
    "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/jane_photo2.jpg"
  ],
  "last_active": "2025-11-17T09:15:00Z"
}
```

**Response (200 OK) - Private Profile (Not Matched):**

```json
{
  "id": 8,
  "display_name": "anon_xyz123",
  "user": {
    "id": 8,
    "username": "sarah_jones",
    "email": "sarah@university.edu",
    "first_name": "Sarah",
    "last_name": "Jones"
  },
  "university_data": {
    "id": 1,
    "name": "Stanford University",
    "slug": "stanford-university",
    "logo": "http://api.example.com/media/universities/logos/stanford.png"
  },
  "display_bio": "Profile is private",
  "gender": "female",
  "intent": "dating",
  "course": "Biology",
  "age": 22,
  "graduation_year": 2027,
  "interests": ["nature", "science"],
  "imageUrls": [
    "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/anon_photo.jpg"
  ],
  "last_active": "2025-11-17T08:45:00Z"
}
```

**Response (200 OK) - Private Profile (Matched & show_real_name_on_match=true):**

```json
{
  "id": 8,
  "display_name": "Sarah Johnson",
  "user": {
    "id": 8,
    "username": "sarah_jones",
    "email": "sarah@university.edu",
    "first_name": "Sarah",
    "last_name": "Jones"
  },
  "university_data": {
    "id": 1,
    "name": "Stanford University",
    "slug": "stanford-university",
    "logo": "http://api.example.com/media/universities/logos/stanford.png"
  },
  "display_bio": "Love biology and nature walks 🌿",
  "gender": "female",
  "intent": "dating",
  "course": "Biology",
  "age": 22,
  "graduation_year": 2027,
  "interests": ["biology", "nature", "hiking"],
  "imageUrls": [
    "https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/sarah_photo.jpg"
  ],
  "last_active": "2025-11-17T08:45:00Z"
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
      "imageUrls": ["https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/jane_photo.jpg"]
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
      "imageUrls": ["https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/sarah_photo.jpg"]
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
      "imageUrls": ["https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/emily_photo.jpg"]
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
      "imageUrls": ["https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/alex_photo.jpg"]
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
      "imageUrls": ["https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/jane_photo.jpg"]
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
    "imageUrls": ["https://res.cloudinary.com/demo/image/upload/v1234567890/profiles/jane_photo.jpg"],
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

**URL:** `ws://localhost:8000/ws/chat/{room_id}/?token={jwt_token}`

**Production URL:** `wss://api.example.com/ws/chat/{room_id}/?token={jwt_token}`

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
    "sender": {
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
  "username": "jane_smith",
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

## WebSocket - Real-time Notifications

### Connection

**URL:** `ws://localhost:8000/ws/notifications/?token={jwt_token}`

**Production URL:** `wss://api.example.com/ws/notifications/?token={jwt_token}`

**Query Parameter:**

```
?token=eyJ0eXAiOiJKV1QiLCJhbGc...
```

### Connection Confirmation (Server → Client)

```json
{
  "type": "connection",
  "message": "Connected to notifications"
}
```

### Match Notification (Server → Client)

Sent when two users like each other and create a match.

```json
{
  "type": "match",
  "match_id": 12,
  "user": {
    "id": 5,
    "username": "jane_smith",
    "display_name": "Jane Smith",
    "image_url": "https://res.cloudinary.com/.../photo.jpg"
  },
  "message": "You matched with Jane Smith!"
}
```

### Profile Like Notification (Server → Client)

Sent when someone likes your profile.

```json
{
  "type": "like",
  "like_type": "profile",
  "liker": {
    "id": 7,
    "username": "emily_wilson",
    "display_name": "Emily Wilson",
    "image_url": "https://res.cloudinary.com/.../photo.jpg"
  },
  "message": "Emily Wilson liked your profile!"
}
```

### Gallery Like Notification (Server → Client)

Sent when someone likes your gallery photo.

```json
{
  "type": "like",
  "like_type": "gallery",
  "liker": {
    "id": 8,
    "username": "alex_brown",
    "display_name": "Alex Brown",
    "image_url": "https://res.cloudinary.com/.../photo.jpg"
  },
  "message": "Alex Brown liked your gallery!"
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
    "date_of_birth": ["You must be at least 18 years old to use this platform."]
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

9. **Universities Endpoint**: `/api/v1.0/profiles/universities/` is publicly accessible without authentication

10. **Registration Flow**: 
    - **Traditional:**
      - Step 1: POST `/auth/users/` (create account)
      - Step 2: POST `/auth/jwt/create/` (login to get token)
      - Step 3: PATCH `/api/v1.0/profiles/me/` (complete profile with university, gender, etc.)
      - Step 4: POST `/api/v1.0/profiles/me/photos/` (optional - upload photos via Cloudinary URLs)
    - **Google OAuth:**
      - Step 1: POST `/auth/google/` (authenticate with Google token)
      - Step 2: PATCH `/api/v1.0/profiles/me/` (complete profile)
      - Step 3: POST `/api/v1.0/profiles/me/photos/` (optional - upload photos)
    - **FCM Token:**
      - POST `/auth/fcm-token/` (update FCM token for push notifications)

11. **Profile Photos**:
    - Photos are stored as Cloudinary URLs in `imageUrls` array
    - `imagePublicIds` array stores Cloudinary public IDs for deletion
    - Maximum 6 photos per profile
    - POST `/api/v1.0/profiles/me/photos/` appends new photos
    - PATCH `/api/v1.0/profiles/me/photos/` replaces all photos
    - DELETE `/api/v1.0/profiles/me/delete_photo/` removes specific photo by publicId

12. **Profile Privacy**:
    - Private profiles show `anon_handle` as `display_name` and hide bio until matched
    - When matched and `show_real_name_on_match=true`, real name is revealed
    - Age is calculated automatically from `date_of_birth` (must be 18+)

13. **Real-time Notifications**:
    - WebSocket endpoint: `ws://localhost:8000/ws/notifications/?token={jwt_token}`
    - Receives real-time notifications for matches, likes, and other events
    - Requires JWT token for authentication
    - See WEBSOCKET_SETUP_GUIDE.md for detailed implementation

14. **Push Notifications**:
    - Firebase Cloud Messaging (FCM) for offline/background notifications
    - Update FCM token via POST `/auth/fcm-token/`
    - Automatically sent when user is offline or app is in background
    - Includes match notifications, like notifications, and message alerts

15. **Google OAuth**:
    - Client ID: `87342870814-ophi6dp8lc2kt7njgle8jgfc1hq6vug7.apps.googleusercontent.com`
    - Authenticate via POST `/auth/google/` with Google ID token
    - Creates new user if doesn't exist
    - Returns JWT tokens for API access

16. **Account Deletion**:
    - DELETE `/auth/delete/` to permanently delete account
    - Cascades to profile, likes, matches, messages, etc.
    - Requires authentication
    - Cannot be undone
