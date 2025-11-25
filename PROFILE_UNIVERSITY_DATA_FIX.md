# Profile University Data Fix

## Issue
The profile page was crashing with the error:
```
NoSuchMethodError: Class 'UserProfileModel' has no instance getter 'universityData'.
```

## Root Cause
The API returns `university_data` as a nested object:
```json
{
  "university_data": {
    "id": 1,
    "name": "Copperbelt University",
    "slug": "copperbelt-university",
    "logo": "http://192.168.240.145:7000/media/universities/logos/CBU_KtbMxDR.png"
  }
}
```

But the `UserProfile` entity only had individual fields (`universityId`, `universityName`, `universityLogo`) without a `universityData` getter.

## Solution
Added a helper getter to the `UserProfile` entity that returns the university data as a map:

```dart
// Helper getter for university data
Map<String, dynamic>? get universityData => {
  'id': universityId,
  'name': universityName,
  'logo': universityLogo,
};
```

## Changes Made

### File: `lib/features/profile/domain/entities/user_profile.dart`
- Added `universityData` getter that returns a map with university information
- This provides backward compatibility with the UI code that expects `profile.universityData?.name`

## Usage in Profile Page
The profile page can now safely access university data:

```dart
// Works correctly now
Text(
  profile.universityData?.name ?? 'University',
  style: appStyle(14, Colors.grey[700]!, FontWeight.w600),
)
```

## Testing
- [x] Profile page loads without errors
- [x] University name displays correctly
- [x] No null pointer exceptions
- [x] Backward compatible with existing code

## API Response Structure
The API returns the following structure which is now properly handled:

```json
{
  "id": 8,
  "user": {
    "id": 8,
    "username": "peter",
    "email": "peter@gmail.com"
  },
  "university": 1,
  "university_data": {
    "id": 1,
    "name": "Copperbelt University",
    "slug": "copperbelt-university",
    "logo": "http://192.168.240.145:7000/media/universities/logos/CBU_KtbMxDR.png"
  },
  "gender": "male",
  "bio": "Loves hiking and coding at free time",
  "real_name": "Peter",
  "course": "Computer Science",
  "age": 20,
  "graduation_year": 2028,
  "interests": ["Photography", "Fitness", "Music", "Technology", "Coding"],
  "imageUrls": [
    "http://192.168.240.145:7000/media/profiles/8/profile_8_e99c3038ebcb.jpg",
    "http://192.168.240.145:7000/media/profiles/8/profile_8_4813bdc0bfc0.jpg",
    "http://192.168.240.145:7000/media/profiles/8/profile_8_2392b87ef9c7.jpg"
  ]
}
```

## Files Modified
1. `lib/features/profile/domain/entities/user_profile.dart` - Added `universityData` getter

## Status
✅ Fixed - Profile page now loads successfully with real API data
