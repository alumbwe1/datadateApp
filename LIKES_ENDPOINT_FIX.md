# Likes Endpoint Fix - Received Likes Not Showing 🔧

## Problem
Received likes were not displaying in the UI even though the API was returning data.

## Root Cause
The app was using the wrong endpoint for fetching received likes:
- **Wrong**: `GET /api/v1.0/interactions/likes/?type=received`
- **Correct**: `GET /api/v1.0/interactions/likes/received/`

The query parameter approach was returning the wrong data structure (showing `liked` instead of `liker`).

## API Response Difference

### Wrong Endpoint Response
```json
{
  "id": 3,
  "liked": {  // ❌ Wrong - shows who YOU liked
    "id": 9,
    "username": "gloria",
    "display_name": "Gloria",
    "profile": {...}
  }
}
```

### Correct Endpoint Response
```json
{
  "id": 25,
  "liker": {  // ✅ Correct - shows who LIKED YOU
    "id": 9,
    "username": "alex_brown",
    "display_name": "Alex Brown",
    "profile": {...}
  }
}
```

## Solution
Updated `InteractionsRemoteDataSourceImpl.getLikes()` to use the dedicated endpoint:

```dart
@override
Future<List<LikeModel>> getLikes({required String type}) async {
  // Use the correct endpoint based on type
  final endpoint = type == 'received' 
      ? ApiEndpoints.receivedLikes  // /api/v1.0/interactions/likes/received/
      : ApiEndpoints.likes;          // /api/v1.0/interactions/likes/
  
  final response = await apiClient.get<Map<String, dynamic>>(endpoint);
  // ... rest of parsing logic
}
```

## Files Changed
- ✅ `lib/features/interactions/data/datasources/interactions_remote_datasource.dart`

## Result
- ✅ Received likes now display correctly
- ✅ Shows the correct user (who liked you, not who you liked)
- ✅ Cards render with proper profile information
- ✅ No code changes needed in UI layer

## Testing
1. Navigate to Likes page
2. Switch to "Received" tab
3. Should see cards for users who liked you
4. Tap card to view their profile

The fix is minimal and surgical - only changed the endpoint selection logic! 🎯
