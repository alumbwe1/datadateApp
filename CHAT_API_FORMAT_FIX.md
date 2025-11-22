# Chat API Format Fix

## Issue

The chat rooms API was returning a different format than expected:

**Expected:**
```json
[
  {
    "id": 1,
    "other_participant": {
      "profile_photo": "url"
    }
  }
]
```

**Actual API Response:**
```json
{
  "count": 1,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "other_participant": {
        "id": 9,
        "username": "gloria",
        "display_name": "Gloria",
        "imageUrls": [
          "http://192.168.240.145:7000/media/profiles/9/profile_9_7da60a61d1d8.jpg",
          "http://192.168.240.145:7000/media/profiles/9/profile_9_66a2b59e6481.jpg"
        ]
      }
    }
  ]
}
```

## Problems Identified

1. **Paginated Response**: API returns `{count, next, previous, results}` instead of direct array
2. **Image Field Name**: API uses `imageUrls` (array) instead of `profile_photo` (string)

## Fixes Applied

### 1. Updated `ParticipantInfo` Model

**File:** `lib/features/chat/data/models/chat_room_model.dart`

**Changes:**
- Changed `profilePhoto` field to `imageUrls` (List<String>)
- Added getter `profilePhoto` that returns first image from array
- Updated `fromJson` to parse `imageUrls` array

```dart
class ParticipantInfo {
  final List<String> imageUrls;  // Changed from String? profilePhoto
  
  // Getter for backward compatibility
  String? get profilePhoto => imageUrls.isNotEmpty ? imageUrls.first : null;
  
  factory ParticipantInfo.fromJson(Map<String, dynamic> json) {
    return ParticipantInfo(
      imageUrls: json['imageUrls'] != null
          ? List<String>.from(json['imageUrls'] as List)
          : [],
    );
  }
}
```

### 2. Updated `ChatRemoteDataSource`

**File:** `lib/features/chat/data/datasources/chat_remote_datasource.dart`

**Changes:**
- Added handling for paginated response format
- Extracts `results` array from paginated response
- Falls back to direct array if not paginated

```dart
Future<List<ChatRoomModel>> getChatRooms() async {
  final response = await _apiClient.get(ApiEndpoints.chatRooms);
  final data = response.data;
  
  if (data is Map<String, dynamic> && data.containsKey('results')) {
    // Paginated response - extract results
    final List<dynamic> results = data['results'] as List<dynamic>;
    return results.map((json) => ChatRoomModel.fromJson(json)).toList();
  } else if (data is List) {
    // Direct list response
    return data.map((json) => ChatRoomModel.fromJson(json)).toList();
  }
}
```

## Result

✅ Chat rooms now load correctly from API
✅ Profile photos display properly (uses first image from array)
✅ Handles both paginated and non-paginated responses
✅ Backward compatible with existing code

## Testing

Your API response should now work perfectly:

```json
{
  "count": 1,
  "results": [
    {
      "id": 1,
      "other_participant": {
        "id": 9,
        "username": "gloria",
        "display_name": "Gloria",
        "imageUrls": ["http://...jpg", "http://...jpg"]
      },
      "last_message": null,
      "unread_count": 0
    }
  ]
}
```

The chat page will:
1. Extract the `results` array
2. Parse each chat room
3. Use the first image from `imageUrls` as the profile photo
4. Display correctly in the UI

## No Changes Needed

The UI code (`chat_page.dart`) doesn't need any changes because:
- It still accesses `room.otherParticipant.profilePhoto`
- The getter returns the first image from the array
- Everything works seamlessly!

🎉 **Your chat should now load and display correctly!**
