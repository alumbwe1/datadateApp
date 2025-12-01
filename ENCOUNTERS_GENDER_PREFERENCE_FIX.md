# Encounters Gender Preference Fix

## Problem
The encounters page was fetching profiles based on the logged-in user's **own gender** instead of their **gender preference**. This caused issues where:
- A female user would see female profiles (instead of male profiles if that's their preference)
- The API was receiving `gender=female` when it should receive the preferred gender

## Root Cause
In `encounters_page.dart`, the code was using:
```dart
ref.read(encountersProvider.notifier).loadProfiles(user.gender);
```

This passed the user's own gender (e.g., "female") to the API, which then returned profiles of the same gender.

## Solution
Changed the implementation to:
1. Load the user's profile on page initialization
2. Extract the `preferredGenders` field from the profile
3. Use the first preferred gender when fetching encounter profiles

### Key Changes

**Before:**
```dart
final user = ref.read(authProvider).user;
if (user != null) {
  ref.read(encountersProvider.notifier).loadProfiles(user.gender);
}
```

**After:**
```dart
await ref.read(profileProvider.notifier).loadProfile();
final profile = ref.read(profileProvider).profile;
if (profile != null && profile.preferredGenders.isNotEmpty) {
  final preferredGender = profile.preferredGenders.first;
  ref.read(encountersProvider.notifier).loadProfiles(preferredGender);
}
```

## Files Modified
- `lib/features/encounters/presentation/pages/encounters_page.dart`
  - Added import for `profile_provider`
  - Created `_loadProfilesWithPreference()` method
  - Updated all places that reload profiles to use preferred gender
  - Removed unused imports

## How It Works Now
1. **On Page Load**: Fetches user profile to get `preferredGenders`
2. **API Call**: Sends the preferred gender (e.g., "male" for a female user who prefers males)
3. **Response**: Receives profiles matching the user's preference
4. **Filters**: All filter operations now use the preferred gender
5. **Refresh**: Retry and refresh buttons use the preferred gender

## API Request Example
**Before (Incorrect):**
```
GET /api/v1.0/profiles/discover/?gender=female
```
A female user would see female profiles.

**After (Correct):**
```
GET /api/v1.0/profiles/discover/?gender=male
```
A female user who prefers males will now see male profiles.

## Testing
To verify the fix:
1. Log in as a user with a specific gender preference
2. Navigate to the Encounters page
3. Check the API logs - the `gender` parameter should match your preference, not your own gender
4. Verify you see profiles of your preferred gender

## Notes
- The fix uses `preferredGenders.first` since the API currently accepts a single gender
- If the API supports multiple preferred genders in the future, this can be extended
- The profile is loaded once on page initialization for efficiency
- All retry/refresh operations maintain the correct gender preference
