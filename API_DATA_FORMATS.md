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

### GET `/api/v1.0/interactions/matches/` - List Matches

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

### GET `/api/v1.0/interactions/likes/` - List Likes (Sent)

Get all likes given by the current user with detailed profile information.

**Response (200 OK):**

```json
[
  {
    "id": 23,
    "liker": {
      "id": 1,
      "username": "john_doe",
      "display_name": "John Doe",
      "profile": {
        "id": 1,
        "bio": "Love coding and coffee!",
        "age": 21,
        "gender": "male",
        "course": "Computer Science",
        "graduation_year": 2026,
        "interests": ["coding", "coffee", "hiking"],
        "imageUrls": ["https://res.cloudinary.com/.../john_photo.jpg"],
        "university": {
          "id": 1,
          "name": "Stanford University",
          "slug": "stanford"
        },
        "last_active": "2025-11-20T10:00:00Z"
      }
    },
    "liked": {
      "id": 7,
      "username": "emily_wilson",
      "display_name": "Emily Wilson",
      "profile": {
        "id": 7,
        "bio": "Nature lover and bookworm",
        "age": 22,
        "gender": "female",
        "course": "Biology",
        "graduation_year": 2025,
        "interests": ["reading", "nature", "photography"],
        "imageUrls": ["https://res.cloudinary.com/.../emily_photo.jpg"],
        "university": {
          "id": 1,
          "name": "Stanford University",
          "slug": "stanford"
        },
        "last_active": "2025-11-20T09:45:00Z"
      }
    },
    "like_type": "profile",
    "gallery_image": null,
    "created_at": "2025-11-15T10:20:00Z"
  }
]
```

### GET `/api/v1.0/interactions/likes/received/` - List Likes Received

Get all likes received by the current user with detailed profile information of who liked you.

**Response (200 OK):**

```json
[
  {
    "id": 25,
    "liker": {
      "id": 9,
      "username": "alex_brown",
      "display_name": "Alex Brown",
      "profile": {
        "id": 9,
        "bio": "Adventure seeker and coffee enthusiast",
        "age": 23,
        "gender": "male",
        "course": "Engineering",
        "graduation_year": 2026,
        "interests": ["adventure", "coffee", "travel"],
        "imageUrls": ["https://res.cloudinary.com/.../alex_photo.jpg"],
        "university": {
          "id": 1,
          "name": "Stanford University",
          "slug": "stanford"
        },
        "last_active": "2025-11-20T11:00:00Z"
      }
    },
    "liked": {
      "id": 1,
      "username": "john_doe",
      "display_name": "John Doe",
      "profile": {
        "id": 1,
        "bio": "Love coding and coffee!",
        "age": 21,
        "gender": "male",
        "course": "Computer Science",
        "graduation_year": 2026,
        "interests": ["coding", "coffee", "hiking"],
        "imageUrls": ["https://res.cloudinary.com/.../john_photo.jpg"],
        "university": {
          "id": 1,
          "name": "Stanford University",
          "slug": "stanford"
        },
        "last_active": "2025-11-20T10:00:00Z"
      }
    },
    "like_type": "profile",
    "gallery_image": null,
    "created_at": "2025-11-15T11:00:00Z"
  }
]
```

### POST `/api/v1.0/interactions/likes/` - Create Like

**Request (Profile Like):**

```json
{
  "liked": 7,
  "like_type": "profile"
}
```

**Response (201 Created - No Match):**

```json
{
  "id": 23,
  "liker": {
    "id": 1,
    "username": "john_doe",
    "display_name": "John Doe",
    "profile": {
      "id": 1,
      "bio": "Love coding and coffee!",
      "age": 21,
      "gender": "male",
      "course": "Computer Science",
      "graduation_year": 2026,
      "interests": ["coding", "coffee", "hiking"],
      "imageUrls": ["https://res.cloudinary.com/.../john_photo.jpg"],
      "university": {
        "id": 1,
        "name": "Stanford University",
        "slug": "stanford"
      },
      "last_active": "2025-11-20T10:00:00Z"
    }
  },
  "liked": {
    "id": 7,
    "username": "emily_wilson",
    "display_name": "Emily Wilson",
    "profile": {
      "id": 7,
      "bio": "Nature lover and bookworm",
      "age": 22,
      "gender": "female",
      "course": "Biology",
      "graduation_year": 2025,
      "interests": ["reading", "nature", "photography"],
      "imageUrls": ["https://res.cloudinary.com/.../emily_photo.jpg"],
      "university": {
        "id": 1,
        "name": "Stanford University",
        "slug": "stanford"
      },
      "last_active": "2025-11-20T09:45:00Z"
    }
  },
  "like_type": "profile",
  "gallery_image": null,
  "created_at": "2025-11-15T10:20:00Z",
  "matched": false
}
```

**Response (201 Created - Match!):**

```json
{
  "id": 23,
  "liker": {
    "id": 1,
    "username": "john_doe",
    "display_name": "John Doe",
    "profile": {
      "id": 1,
      "bio": "Love coding and coffee!",
      "age": 21,
      "gender": "male",
      "course": "Computer Science",
      "graduation_year": 2026,
      "interests": ["coding", "coffee", "hiking"],
      "imageUrls": ["https://res.cloudinary.com/.../john_photo.jpg"],
      "university": {
        "id": 1,
        "name": "Stanford University",
        "slug": "stanford"
      },
      "last_active": "2025-11-20T10:00:00Z"
    }
  },
  "liked": {
    "id": 7,
    "username": "emily_wilson",
    "display_name": "Emily Wilson",
    "profile": {
      "id": 7,
      "bio": "Nature lover and bookworm",
      "age": 22,
      "gender": "female",
      "course": "Biology",
      "graduation_year": 2025,
      "interests": ["reading", "nature", "photography"],
      "imageUrls": ["https://res.cloudinary.com/.../emily_photo.jpg"],
      "university": {
        "id": 1,
        "name": "Stanford University",
        "slug": "stanford"
      },
      "last_active": "2025-11-20T09:45:00Z"
    }
  },
  "like_type": "profile",
  "gallery_image": null,
  "created_at": "2025-11-15T10:20:00Z",
  "matched": true,
  "match_id": 12,
  "message": "It's a match!"
}
```

**Request (Gallery Like):**

```json
{
  "liked": 7,
  "like_type": "gallery",
  "gallery_image": 5
}
```

**Response (201 Created):**

```json
{
  "id": 24,
  "liker": 1,
  "liked": 7,
  "like_type": "gallery",
  "gallery_image": 5,
  "created_at": "2025-11-15T10:25:00Z",
  "matched": false
}
```

**Error (400 Bad Request - Already Liked):**

```json
{
  "detail": "You have already liked this profile."
}
```

**Error (400 Bad Request - Self Like):**

```json
{
  "detail": "You cannot like yourself."
}
```

### DELETE `/api/v1.0/interactions/likes/{id}/` - Unlike

**Response (200 OK):**

```json
{
  "detail": "Like removed successfully."
}
```

### GET `/api/v1.0/interactions/profile-views/` - List Profile Views

Get all profile views made by the current user.

**Response (200 OK):**

```json
[
  {
    "id": 45,
    "viewer": 1,
    "viewed": 9,
    "viewed_at": "2025-11-15T09:30:00Z"
  }
]
```

### GET `/api/v1.0/interactions/profile-views/received/` - List Profile Views Received

Get all profile views received by the current user.

**Response (200 OK):**

```json
[
  {
    "id": 46,
    "viewer": 10,
    "viewed": 1,
    "viewed_at": "2025-11-15T10:00:00Z"
  }
]
```

**Note:** Profile views are automatically recorded when viewing a profile via GET `/api/v1.0/profiles/{id}/`

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


---

## 

---


## Profile Boost System

### GET `/api/v1.0/profiles/boosts/pricing/` - Get Boost Pricing (No Auth Required)

**Response (200 OK):**

```json
{
  "min_amount": 5.0,
  "default_duration_hours": 2,
  "currency": "ZMW",
  "enabled": true
}
```

### POST `/api/v1.0/profiles/boosts/` - Create Profile Boost

**Request:**

```json
{
  "amount_paid": 10.00,
  "target_views": 100,
  "duration_hours": 2
}
```

**Response (201 Created):**

```json
{
  "message": "Boost created successfully. Complete payment to activate.",
  "boost": {
    "id": 1,
    "username": "john_doe",
    "amount_paid": "10.00",
    "target_views": 100,
    "duration_hours": 2,
    "current_views": 0,
    "status": "pending",
    "progress_percentage": 0,
    "time_remaining": 0,
    "started_at": null,
    "expires_at": null,
    "completed_at": null,
    "created_at": "2025-11-23T10:00:00Z"
  }
}
```

**Error (403 Forbidden - Features Disabled):**

```json
{
  "error": "Paid features are currently disabled"
}
```

**Error (400 Bad Request - Active Boost Exists):**

```json
{
  "error": "You already have an active boost",
  "active_boost": {
    "id": 1,
    "amount_paid": "10.00",
    "status": "active",
    "expires_at": "2025-11-23T12:00:00Z"
  }
}
```

### POST `/api/v1.0/profiles/boosts/{id}/activate/` - Activate Boost After Payment

**Response (200 OK):**

```json
{
  "message": "Boost activated successfully",
  "boost": {
    "id": 1,
    "username": "john_doe",
    "amount_paid": "10.00",
    "target_views": 100,
    "duration_hours": 2,
    "current_views": 0,
    "status": "active",
    "progress_percentage": 0,
    "time_remaining": 7200,
    "started_at": "2025-11-23T10:00:00Z",
    "expires_at": "2025-11-23T12:00:00Z",
    "completed_at": null,
    "created_at": "2025-11-23T10:00:00Z"
  }
}
```

### GET `/api/v1.0/profiles/boosts/active/` - Get Active Boost

**Response (200 OK):**

```json
{
  "id": 1,
  "username": "john_doe",
  "amount_paid": "10.00",
  "target_views": 100,
  "duration_hours": 2,
  "current_views": 45,
  "status": "active",
  "progress_percentage": 45.0,
  "time_remaining": 3600,
  "started_at": "2025-11-23T10:00:00Z",
  "expires_at": "2025-11-23T12:00:00Z",
  "completed_at": null,
  "created_at": "2025-11-23T10:00:00Z"
}
```

**Response (404 Not Found):**

```json
{
  "message": "No active boost"
}
```

### GET `/api/v1.0/profiles/boosts/history/` - Get Boost History

**Response (200 OK):**

```json
[
  {
    "id": 2,
    "username": "john_doe",
    "amount_paid": "15.00",
    "target_views": 150,
    "duration_hours": 3,
    "current_views": 150,
    "status": "completed",
    "progress_percentage": 100.0,
    "time_remaining": 0,
    "started_at": "2025-11-22T10:00:00Z",
    "expires_at": "2025-11-22T13:00:00Z",
    "completed_at": "2025-11-22T12:30:00Z",
    "created_at": "2025-11-22T10:00:00Z"
  },
  {
    "id": 1,
    "username": "john_doe",
    "amount_paid": "10.00",
    "target_views": 100,
    "duration_hours": 2,
    "current_views": 85,
    "status": "expired",
    "progress_percentage": 85.0,
    "time_remaining": 0,
    "started_at": "2025-11-21T10:00:00Z",
    "expires_at": "2025-11-21T12:00:00Z",
    "completed_at": "2025-11-21T12:00:00Z",
    "created_at": "2025-11-21T10:00:00Z"
  }
]
```

---

## Advanced Profile Discovery & Filtering

### GET `/api/v1.0/profiles/discover/` - Discover Profiles with Filters

**Query Parameters:**

```
?gender=female
&min_age=20
&max_age=25
&city=Lusaka
&compound=Meanwood
&university_id=1
&course=Computer
&graduation_year=2026
&intent=dating
&interests=hiking,coffee
&online_only=true
&has_photos=true
&occupation_type=student
```

**Response (200 OK):**

```json
[
  {
    "id": 5,
    "display_name": "Jane Smith",
    "user": {
      "id": 5,
      "username": "jane_smith",
      "email": "jane@university.edu"
    },
    "university_data": {
      "id": 1,
      "name": "University of Zambia",
      "slug": "unza"
    },
    "display_bio": "Love hiking and coffee ☕",
    "gender": "female",
    "intent": "dating",
    "age": 21,
    "course": "Computer Science",
    "graduation_year": 2026,
    "city": "Lusaka",
    "compound": "Meanwood",
    "occupation_type": "student",
    "interests": ["hiking", "coffee", "reading"],
    "imageUrls": ["https://res.cloudinary.com/.../photo.jpg"],
    "last_active": "2025-11-23T10:00:00Z"
  }
]
```

### GET `/api/v1.0/profiles/discover/recommended/` - Get Recommended Profiles

Returns profiles based on user preferences, same university, excludes already liked/matched.

**Response (200 OK):**

```json
[
  {
    "id": 7,
    "display_name": "Emily Wilson",
    "gender": "female",
    "age": 22,
    "course": "Biology",
    "city": "Lusaka",
    "interests": ["nature", "photography"],
    "imageUrls": ["https://res.cloudinary.com/.../photo.jpg"],
    "last_active": "2025-11-23T09:45:00Z"
  }
]
```

### GET `/api/v1.0/profiles/discover/nearby/` - Get Nearby Profiles

**Query Parameters:**

```
?same_compound=true
```

**Response (200 OK):**

```json
[
  {
    "id": 8,
    "display_name": "Sarah Jones",
    "city": "Lusaka",
    "compound": "Meanwood",
    "age": 23,
    "imageUrls": ["https://res.cloudinary.com/.../photo.jpg"]
  }
]
```

### GET `/api/v1.0/profiles/discover/students/` - Get Student Profiles

**Query Parameters:**

```
?university_id=1&course=Computer
```

**Response (200 OK):**

```json
[
  {
    "id": 9,
    "display_name": "Alex Brown",
    "occupation_type": "student",
    "university_data": {
      "id": 1,
      "name": "University of Zambia"
    },
    "course": "Computer Science",
    "graduation_year": 2026,
    "imageUrls": ["https://res.cloudinary.com/.../photo.jpg"]
  }
]
```

### GET `/api/v1.0/profiles/discover/boosted/` - Get Boosted Profiles

**Response (200 OK):**

```json
[
  {
    "id": 10,
    "display_name": "Mike Johnson",
    "age": 24,
    "course": "Engineering",
    "imageUrls": ["https://res.cloudinary.com/.../photo.jpg"],
    "last_active": "2025-11-23T10:30:00Z"
  }
]
```

---

## Blocking & Reporting

### POST `/api/v1.0/profiles/blocked-users/` - Block a User

**Request:**

```json
{
  "blocked_user_id": 123,
  "reason": "Inappropriate behavior"
}
```

**Response (201 Created):**

```json
{
  "message": "User blocked successfully",
  "block": {
    "id": 1,
    "blocker_username": "john_doe",
    "blocked_username": "spam_user",
    "blocked_user_id": 123,
    "reason": "Inappropriate behavior",
    "created_at": "2025-11-23T10:00:00Z"
  }
}
```

**Error (400 Bad Request - Self Block):**

```json
{
  "error": "Cannot block yourself"
}
```

**Error (400 Bad Request - Already Blocked):**

```json
{
  "error": "User is already blocked"
}
```

### GET `/api/v1.0/profiles/blocked-users/` - List Blocked Users

**Response (200 OK):**

```json
[
  {
    "id": 1,
    "blocker_username": "john_doe",
    "blocked_username": "spam_user",
    "blocked_user_id": 123,
    "reason": "Inappropriate behavior",
    "created_at": "2025-11-23T10:00:00Z"
  }
]
```

### DELETE `/api/v1.0/profiles/blocked-users/{id}/` - Unblock User

**Response (200 OK):**

```json
{
  "message": "User spam_user unblocked successfully"
}
```

### POST `/api/v1.0/profiles/blocked-users/check/` - Check Block Status

**Request:**

```json
{
  "user_id": 123
}
```

**Response (200 OK):**

```json
{
  "is_blocked": false,
  "is_blocked_by": false,
  "can_interact": true
}
```

### POST `/api/v1.0/profiles/reports/` - Create Report

**Request:**

```json
{
  "reported_user_id": 123,
  "report_type": "user",
  "reason": "harassment",
  "description": "User sent inappropriate messages repeatedly",
  "message_id": "msg_456"
}
```

**Report Types:** `user`, `message`, `profile`

**Reasons:** `spam`, `harassment`, `inappropriate_content`, `fake_profile`, `scam`, `other`

**Response (201 Created):**

```json
{
  "message": "Report submitted successfully",
  "report": {
    "id": 1,
    "reporter_username": "john_doe",
    "reported_username": "bad_user",
    "report_type": "user",
    "reason": "harassment",
    "description": "User sent inappropriate messages repeatedly",
    "message_id": "msg_456",
    "status": "pending",
    "admin_notes": "",
    "resolved_at": null,
    "resolved_by_username": null,
    "created_at": "2025-11-23T10:00:00Z",
    "updated_at": "2025-11-23T10:00:00Z"
  }
}
```

**Error (400 Bad Request - Self Report):**

```json
{
  "error": "Cannot report yourself"
}
```

### GET `/api/v1.0/profiles/reports/my_reports/` - Get My Reports

**Response (200 OK):**

```json
[
  {
    "id": 1,
    "reporter_username": "john_doe",
    "reported_username": "bad_user",
    "report_type": "user",
    "reason": "harassment",
    "status": "pending",
    "created_at": "2025-11-23T10:00:00Z"
  }
]
```

### GET `/api/v1.0/profiles/reports/pending/` - Get Pending Reports (Admin Only)

**Response (200 OK):**

```json
[
  {
    "id": 1,
    "reporter_username": "john_doe",
    "reported_username": "bad_user",
    "report_type": "user",
    "reason": "harassment",
    "description": "User sent inappropriate messages repeatedly",
    "status": "pending",
    "created_at": "2025-11-23T10:00:00Z"
  }
]
```

### POST `/api/v1.0/profiles/reports/{id}/resolve/` - Resolve Report (Admin Only)

**Request:**

```json
{
  "notes": "User warned and content removed"
}
```

**Response (200 OK):**

```json
{
  "message": "Report resolved successfully",
  "report": {
    "id": 1,
    "status": "resolved",
    "admin_notes": "User warned and content removed",
    "resolved_at": "2025-11-23T11:00:00Z",
    "resolved_by_username": "admin_user"
  }
}
```

### POST `/api/v1.0/profiles/reports/{id}/dismiss/` - Dismiss Report (Admin Only)

**Request:**

```json
{
  "notes": "No violation found"
}
```

**Response (200 OK):**

```json
{
  "message": "Report dismissed successfully",
  "report": {
    "id": 1,
    "status": "dismissed",
    "admin_notes": "No violation found",
    "resolved_at": "2025-11-23T11:00:00Z",
    "resolved_by_username": "admin_user"
  }
}
```

---

## Crush Messages

### POST `/api/v1.0/interactions/crush-messages/` - Send Crush Message

**Request:**

```json
{
  "receiver_id": 123,
  "message": "Hey! I'd love to get to know you better 😊"
}
```

**Response (201 Created):**

```json
{
  "message": "Crush message sent successfully",
  "crush_message": {
    "id": 1,
    "sender_id": 1,
    "sender_username": "john_doe",
    "receiver_id": 123,
    "receiver_username": "jane_smith",
    "message": "Hey! I'd love to get to know you better 😊",
    "status": "pending",
    "read_at": null,
    "responded_at": null,
    "created_at": "2025-11-23T10:00:00Z"
  }
}
```

**Error (403 Forbidden - Features Disabled):**

```json
{
  "error": "Matching features are currently disabled"
}
```

**Error (400 Bad Request - Already Matched):**

```json
{
  "receiver_id": ["You are already matched with this user"]
}
```

**Error (400 Bad Request - Pending Message Exists):**

```json
{
  "receiver_id": ["You already have a pending crush message to this user"]
}
```

### GET `/api/v1.0/interactions/crush-messages/sent/` - Get Sent Crush Messages

**Response (200 OK):**

```json
[
  {
    "id": 1,
    "sender_id": 1,
    "sender_username": "john_doe",
    "receiver_id": 123,
    "receiver_username": "jane_smith",
    "message": "Hey! I'd love to get to know you better 😊",
    "status": "pending",
    "read_at": null,
    "responded_at": null,
    "created_at": "2025-11-23T10:00:00Z"
  }
]
```

### GET `/api/v1.0/interactions/crush-messages/received/` - Get Received Crush Messages

**Response (200 OK):**

```json
[
  {
    "id": 2,
    "sender_id": 456,
    "sender_username": "alex_brown",
    "receiver_id": 1,
    "receiver_username": "john_doe",
    "message": "Hi! You seem really interesting!",
    "status": "pending",
    "read_at": null,
    "responded_at": null,
    "created_at": "2025-11-23T09:30:00Z"
  }
]
```

### GET `/api/v1.0/interactions/crush-messages/pending/` - Get Pending Received Messages

**Response (200 OK):**

```json
[
  {
    "id": 2,
    "sender_id": 456,
    "sender_username": "alex_brown",
    "receiver_id": 1,
    "receiver_username": "john_doe",
    "message": "Hi! You seem really interesting!",
    "status": "pending",
    "read_at": null,
    "responded_at": null,
    "created_at": "2025-11-23T09:30:00Z"
  }
]
```

### POST `/api/v1.0/interactions/crush-messages/{id}/mark_read/` - Mark as Read

**Response (200 OK):**

```json
{
  "message": "Crush message marked as read",
  "crush_message": {
    "id": 2,
    "status": "read",
    "read_at": "2025-11-23T10:15:00Z"
  }
}
```

### POST `/api/v1.0/interactions/crush-messages/{id}/respond/` - Respond to Crush Message

**Request (Accept):**

```json
{
  "action": "accept"
}
```

**Response (200 OK - Accept):**

```json
{
  "message": "Crush message accepted. You are now matched!",
  "crush_message": {
    "id": 2,
    "status": "accepted",
    "responded_at": "2025-11-23T10:20:00Z"
  },
  "match_created": true
}
```

**Request (Decline):**

```json
{
  "action": "decline"
}
```

**Response (200 OK - Decline):**

```json
{
  "message": "Crush message declined",
  "crush_message": {
    "id": 2,
    "status": "declined",
    "responded_at": "2025-11-23T10:20:00Z"
  }
}
```

---

## System Configuration

### GET `/api/v1.0/profiles/system/status/` - Get System Status (Public, No Auth)

**Response (200 OK):**

```json
{
  "mode": "active",
  "is_maintenance": false,
  "maintenance_message": "",
  "features_enabled": {
    "matching": true,
    "chat": true,
    "boost": true,
    "premium": true
  }
}
```

**Response (Maintenance Mode):**

```json
{
  "mode": "maintenance",
  "is_maintenance": true,
  "maintenance_message": "System under maintenance. Back soon!",
  "features_enabled": {
    "matching": false,
    "chat": false,
    "boost": false,
    "premium": false
  }
}
```

### GET `/api/v1.0/profiles/system-config/` - Get System Configuration (Admin Only)

**Response (200 OK):**

```json
{
  "id": 1,
  "mode": "active",
  "paid_features_enabled": true,
  "boost_enabled": true,
  "premium_enabled": true,
  "matching_enabled": true,
  "chat_enabled": true,
  "min_boost_amount": "5.00",
  "boost_default_duration": 2,
  "premium_weekly_price": "20.00",
  "premium_monthly_price": "50.00",
  "premium_yearly_price": "500.00",
  "maintenance_message": "",
  "trial_expires_at": null,
  "updated_at": "2025-11-23T10:00:00Z",
  "updated_by_username": "admin_user"
}
```

### PATCH `/api/v1.0/profiles/system-config/1/` - Update System Configuration (Admin Only)

**Request:**

```json
{
  "mode": "active",
  "paid_features_enabled": true,
  "boost_enabled": true,
  "min_boost_amount": "10.00"
}
```

**Response (200 OK):**

```json
{
  "message": "System configuration updated successfully",
  "config": {
    "id": 1,
    "mode": "active",
    "paid_features_enabled": true,
    "boost_enabled": true,
    "min_boost_amount": "10.00",
    "updated_at": "2025-11-23T11:00:00Z",
    "updated_by_username": "admin_user"
  }
}
```

### POST `/api/v1.0/profiles/system-config/set_trial_mode/` - Set Trial Mode (Admin Only)

**Response (200 OK):**

```json
{
  "message": "System set to trial mode. All paid features disabled.",
  "config": {
    "mode": "trial",
    "paid_features_enabled": false
  }
}
```

### POST `/api/v1.0/profiles/system-config/set_active_mode/` - Set Active Mode (Admin Only)

**Response (200 OK):**

```json
{
  "message": "System set to active mode.",
  "config": {
    "mode": "active",
    "paid_features_enabled": true
  }
}
```

### POST `/api/v1.0/profiles/system-config/set_maintenance_mode/` - Set Maintenance Mode (Admin Only)

**Request:**

```json
{
  "message": "System under maintenance. Back at 3 PM."
}
```

**Response (200 OK):**

```json
{
  "message": "System set to maintenance mode.",
  "config": {
    "mode": "maintenance",
    "maintenance_message": "System under maintenance. Back at 3 PM."
  }
}
```

### POST `/api/v1.0/profiles/system-config/toggle_feature/` - Toggle Feature (Admin Only)

**Request:**

```json
{
  "feature": "boost_enabled",
  "enabled": false
}
```

**Valid Features:** `paid_features_enabled`, `boost_enabled`, `premium_enabled`, `matching_enabled`, `chat_enabled`

**Response (200 OK):**

```json
{
  "message": "boost_enabled disabled successfully",
  "config": {
    "boost_enabled": false
  }
}
```

---

## Updated Profile Fields

### PATCH `/api/v1.0/profiles/me/` - Update Profile with New Fields

**Request:**

```json
{
  "occupation_type": "student",
  "university": 1,
  "course": "Computer Science",
  "graduation_year": 2026,
  "city": "Lusaka",
  "compound": "Meanwood",
  "work_place": "",
  "profile_tier": "standard"
}
```

**Or for working professionals:**

```json
{
  "occupation_type": "working",
  "work_place": "Tech Company Ltd",
  "city": "Lusaka",
  "compound": "Kabulonga",
  "university": null,
  "course": "",
  "graduation_year": null
}
```

**Occupation Types:** `student`, `working`

**Profile Tiers:** `standard`, `premium`

**Response (200 OK):**

```json
{
  "id": 1,
  "occupation_type": "student",
  "university_data": {
    "id": 1,
    "name": "University of Zambia"
  },
  "course": "Computer Science",
  "graduation_year": 2026,
  "city": "Lusaka",
  "compound": "Meanwood",
  "work_place": "",
  "profile_tier": "standard",
  "premium_until": null
}
```

---

## Premium Features

### Profile Tier Isolation

- **Standard users** only see other standard profiles in discovery
- **Premium users** only see other premium profiles in discovery
- Premium status is automatically managed through subscriptions

### Premium Subscription Response

When a subscription is activated, the profile is automatically upgraded:

```json
{
  "profile_tier": "premium",
  "premium_until": "2025-12-23T10:00:00Z"
}
```

---

## Notes - Production Features

17. **Profile Boost System**:
    - Minimum K5 payment required
    - User specifies target views and duration (default 2 hours)
    - Real-time progress tracking
    - Boosted profiles appear first in discovery
    - System can disable boosts via configuration

18. **Advanced Filtering**:
    - Filter by age range, gender, location, university
    - Filter by occupation type (student/working)
    - Filter by city and compound
    - Online status filtering
    - Interest-based filtering
    - Recommended profiles based on preferences

19. **Blocking & Reporting**:
    - Block users to prevent all interactions
    - Report users, messages, or profiles
    - Admin dashboard for report management
    - Multiple report reasons (spam, harassment, etc.)
    - Blocked users cannot see each other's profiles

20. **Crush Messages**:
    - Send ONE message before matching
    - Receiver can accept (creates match) or decline
    - Cannot send if already matched or blocked
    - Read receipts and response tracking

21. **System Configuration**:
    - Three modes: trial, active, maintenance
    - Feature toggles for boost, premium, matching, chat
    - Configurable pricing for boosts and premium
    - Public status endpoint for app state checking
    - Admin-only configuration management

22. **Match-Required Chat**:
    - Chat ONLY allowed after users match
    - WebSocket connection validates match status
    - Applies to all chat interactions
    - Connection rejected if not matched

23. **Student & Work Profiles**:
    - `occupation_type`: student or working
    - Students have university, course, graduation year
    - Working professionals have work_place
    - Both have city and compound fields
    - Filterable by all occupation fields

24. **Premium Tier System**:
    - Standard users see only standard profiles
    - Premium users see only premium profiles
    - Automatic tier management via subscriptions
    - Enhanced visibility for premium users

25. **Production Ready**:
    - All features have proper error handling
    - Admin controls for system management
    - Feature flags for gradual rollout
    - Trial mode for testing without payments
    - Maintenance mode for system updates
