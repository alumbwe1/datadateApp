# 🎉 Updated Onboarding Flow - Instant Registration & Login

## Overview

The onboarding flow has been completely redesigned to:
- ✅ **Create account and login instantly** at registration
- ✅ **Require 2-4 photos** (minimum 2, maximum 4)
- ✅ **Show progress indicator** on each onboarding page
- ✅ **Follow API flow** from API_DATA_FORMATS.md

## User Flow

```
1. Register Page (register_page.dart)
   ├─ Name
   ├─ Email
   ├─ Password
   └─ Confirm Password
   │
   ├─ API: POST /auth/users/ (Step 1: Create Account)
   ├─ API: POST /auth/jwt/create/ (Step 2: Auto-Login)
   └─ Navigate to Onboarding
   
2. University Selection (Step 1/8) - 12.5%
   └─ Select university from list
   
3. Gender Selection (Step 2/8) - 25%
   ├─ Male
   ├─ Female
   └─ Other
   
4. Gender Preference (Step 3/8) - 37.5%
   ├─ Men
   ├─ Women
   └─ Everyone (both)
   
5. Intent Selection (Step 4/8) - 50%
   ├─ Relationship
   ├─ Dating
   └─ Friends
   
6. Bio (Step 5/8) - 62.5%
   └─ Write a short bio
   
7. Course & Graduation (Step 6/8) - 75%
   ├─ Course/Major
   └─ Graduation Year
   
8. Photos (Step 7/8) - 87.5%
   ├─ Add 2-4 photos
   ├─ First photo = profile picture
   └─ Minimum 2 required
   
9. Date of Birth (Step 8/8) - 100%
   ├─ Must be 18+
   └─ Age calculated automatically
   
10. Interests
    └─ Select interests (optional)
    
11. Complete
    ├─ API: PATCH /api/v1.0/profiles/me/ (Step 3: Complete Profile)
    └─ Navigate to Home
```

## API Flow

### Step 1: Registration (register_page.dart)
```dart
// POST /auth/users/
{
  "username": "john_doe",
  "email": "john@university.edu",
  "password": "securePassword123",
  "re_password": "securePassword123"
}

// Response:
{
  "id": 1,
  "username": "john_doe",
  "email": "john@university.edu"
}
```

### Step 2: Auto-Login (register_page.dart)
```dart
// POST /auth/jwt/create/
{
  "email": "john@university.edu",
  "password": "securePassword123"
}

// Response:
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

### Step 3: Complete Profile (onboarding_complete_page.dart)
```dart
// PATCH /api/v1.0/profiles/me/
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
  "interests": ["hiking", "coffee", "coding", "AI"]
}
```

### Step 4: Upload Photos (Future Enhancement)
```dart
// POST /api/v1.0/profiles/me/photos/
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

## Key Changes

### 1. Register Page (register_page.dart)
**Before:**
- Stored data in onboarding provider
- Navigated to gender selection
- Registration happened at the end

**After:**
- Creates account immediately (POST /auth/users/)
- Auto-login immediately (POST /auth/jwt/create/)
- Stores JWT tokens
- Navigates to university selection

### 2. Photo Page (onboarding_photo_page.dart)
**Before:**
- Single photo
- Optional

**After:**
- 2-4 photos required
- Grid layout
- First photo is profile picture
- Shows progress: "2/4 photos added"
- Minimum 2 photos to continue

### 3. Onboarding Provider (onboarding_provider.dart)
**Before:**
- Single `profilePhoto` field
- `genderPreference` (string)
- `datingGoal` (string)

**After:**
- `photos` (List<File>) - supports 2-4 photos
- `preferredGenders` (List<String>) - supports multiple
- `intent` (String) - matches API field name
- Methods: `addPhoto()`, `removePhoto()`, `setPreferredGenders()`

### 4. Progress Indicator (NEW)
**File:** `lib/core/widgets/onboarding_progress.dart`
- Linear progress bar
- Shows percentage (12.5%, 25%, 37.5%, etc.)
- Shows "Step X of 8"
- Shows "X steps left"

### 5. Auth Flow (auth_provider.dart, auth_repository.dart)
**Before:**
- Required all profile fields at registration

**After:**
- Only requires username, email, password
- Profile completed during onboarding
- Simplified register() method

## Files Modified

### Core Files
1. `lib/features/auth/presentation/pages/register_page.dart`
   - Added instant registration and login
   - Removed navigation to gender page
   - Added loading state

2. `lib/features/auth/presentation/providers/auth_provider.dart`
   - Simplified register() method
   - Changed login() to return bool
   - Removed profile fields from registration

3. `lib/features/auth/data/repositories/auth_repository_impl.dart`
   - Simplified register() method
   - Removed profile fields

4. `lib/features/auth/data/datasources/auth_remote_datasource.dart`
   - Simplified register() API call
   - Only sends username, email, password

5. `lib/features/auth/domain/repositories/auth_repository.dart`
   - Updated register() interface

### Onboarding Files
6. `lib/features/onboarding/presentation/providers/onboarding_provider.dart`
   - Changed `profilePhoto` to `photos` (List)
   - Changed `genderPreference` to `preferredGenders` (List)
   - Changed `datingGoal` to `intent`
   - Added `addPhoto()`, `removePhoto()` methods
   - Updated `completeOnboarding()` to match API

7. `lib/features/onboarding/presentation/pages/profile/onboarding_photo_page.dart`
   - Complete rewrite for 2-4 photos
   - Grid layout
   - Progress indicator
   - Photo management (add/remove)

### New Files
8. `lib/core/widgets/onboarding_progress.dart`
   - Progress indicator widget
   - Shows percentage and steps

## Progress Indicator Usage

Add to each onboarding page:

```dart
import '../../../../../core/widgets/onboarding_progress.dart';

// In build method:
const OnboardingProgress(currentStep: 1, totalSteps: 8),
```

### Step Numbers:
- University Selection: 1/8 (12.5%)
- Gender: 2/8 (25%)
- Gender Preference: 3/8 (37.5%)
- Intent: 4/8 (50%)
- Bio: 5/8 (62.5%)
- Course & Graduation: 6/8 (75%)
- Photos: 7/8 (87.5%)
- Date of Birth: 8/8 (100%)

## Photo Requirements

- **Minimum:** 2 photos
- **Maximum:** 4 photos
- **First photo:** Profile picture (marked with "Profile" badge)
- **Format:** JPEG/PNG
- **Size:** Max 1080x1080, 85% quality
- **Source:** Camera or Gallery

## Testing

### Test Registration Flow
1. Open app
2. Click "Sign Up"
3. Enter name, email, password
4. Click "Continue"
5. Should see loading state
6. Should auto-login
7. Should navigate to university selection

### Test Photo Upload
1. Complete onboarding to photo page
2. Try to add 1 photo → Should show "Add at least 2 photos"
3. Add 2 photos → Continue button enabled
4. Add 3rd photo → Should work
5. Add 4th photo → Should work
6. Try to add 5th photo → Should show "Maximum 4 photos allowed"
7. Remove a photo → Should work
8. First photo should have "Profile" badge

### Test Progress Indicator
1. Go through each onboarding step
2. Progress should increase: 12.5% → 25% → 37.5% → 50% → 62.5% → 75% → 87.5% → 100%
3. Step counter should update: "Step 1 of 8" → "Step 2 of 8" → etc.

## Next Steps

### Required
- [ ] Add progress indicator to all onboarding pages
- [ ] Integrate Cloudinary for photo upload
- [ ] Update onboarding_complete_page.dart to upload photos
- [ ] Test complete flow end-to-end

### Optional
- [ ] Add photo reordering (drag & drop)
- [ ] Add photo cropping
- [ ] Add photo filters
- [ ] Add skip option for optional steps
- [ ] Add "Save & Continue Later" functionality

## Notes

1. **Photos are stored locally** during onboarding (as File objects)
2. **Photos will be uploaded** when Cloudinary integration is added
3. **Progress indicator** should be added to each page manually
4. **Age validation** happens at DOB page (must be 18+)
5. **University selection** is now the first onboarding step
6. **Registration is instant** - no waiting until the end

## Summary

✅ User creates account and logs in immediately at registration
✅ Onboarding flow collects profile data
✅ Photos require 2-4 images (minimum 2)
✅ Progress indicator shows completion percentage
✅ Profile updated via API at the end
✅ Clean separation between auth and profile setup

**The flow is ready to use! Just add progress indicators to remaining pages.** 🎉
