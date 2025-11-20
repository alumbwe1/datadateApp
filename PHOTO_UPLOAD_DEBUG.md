# Photo Upload Implementation - Debug Enabled

## Changes Made

### 1. API Endpoint Added

**File**: `lib/core/constants/api_endpoints.dart`

- Added: `uploadProfilePhotos = '/api/v1.0/profiles/me/photos/'`

### 2. Profile Remote Data Source

**File**: `lib/features/profile/data/datasources/profile_remote_datasource.dart`

#### New Method: `uploadProfilePhotos()`

- Uploads **multiple photos in a single request**
- Uses FormData with `images` field containing array of MultipartFile
- Comprehensive debug logging:
  - Request endpoint and file count
  - Each file path being added
  - FormData structure (fields and files count)
  - Full response data
  - Error details including status code and response body

#### Debug Output Example:

```
📤 Uploading 3 photos to: /api/v1.0/profiles/me/photos/
📁 Adding photo 1: /path/to/photo1.jpg
📁 Adding photo 2: /path/to/photo2.jpg
📁 Adding photo 3: /path/to/photo3.jpg
📦 FormData created with 3 images
📦 FormData fields: []
📦 FormData files: 3
✅ Upload response: {imageUrls: [...], imagePublicIds: [...]}
✅ Uploaded 3 photos successfully
```

### 3. Profile Repository

**Files**:

- `lib/features/profile/domain/repositories/profile_repository.dart`
- `lib/features/profile/data/repositories/profile_repository_impl.dart`

#### New Method: `uploadProfilePhotos()`

- Returns `Either<Failure, List<String>>` with uploaded photo URLs
- Handles DioException with detailed error messages

### 4. Profile Provider

**File**: `lib/features/profile/presentation/providers/profile_provider.dart`

#### New Method: `uploadPhotos()`

- Takes list of file paths
- Uploads all photos at once
- Debug logging for success/failure
- Reloads profile after successful upload

### 5. Onboarding Provider

**File**: `lib/features/onboarding/presentation/providers/onboarding_provider.dart`

#### Updated: `_uploadPhotos()`

- **Changed from**: Uploading photos one by one in a loop
- **Changed to**: Uploading all photos in a single request
- Debug output shows:
  - Total number of photos
  - All file paths being uploaded
  - Success/failure status

#### Updated: `completeOnboarding()`

Enhanced debug logging for profile data:

```
📦 Profile data to be sent:
  - University ID: 123
  - Gender: male
  - Preferred Genders: [female]
  - Intent: dating
  - Bio: My bio text
  - Course: Computer Science
  - Interests: [coding, music, sports]
  - Graduation Year: 2025
  - Real Name: John Doe
  - Date of Birth: 2000-01-15
  - Is Private: false
  - Show Real Name on Match: true
```

### 6. Onboarding Complete Page

**File**: `lib/features/onboarding/presentation/pages/onboarding_complete_page.dart`

- Added try-catch for better error handling
- Shows detailed error messages in snackbar

## Flow

1. **User completes onboarding** → Clicks "Start Exploring"
2. **Photos uploaded first** (if any):
   - All photos sent in single POST request to `/api/v1.0/profiles/me/photos/`
   - Debug logs show each file path and upload status
3. **Profile updated**:
   - PATCH request to `/api/v1.0/profiles/me/`
   - Debug logs show all profile data being sent
4. **Navigation** → User redirected to encounters page

## Testing

Run the app and complete onboarding. Check the console for debug output:

```bash
flutter run
```

Look for these log patterns:

- `🚀 Starting onboarding completion...`
- `📸 Uploading X photos...`
- `📤 Uploading X photos in a single request`
- `📁 Photo paths:`
- `📦 FormData created with X images`
- `✅ Upload response: {...}`
- `📦 Profile data to be sent:`
- `✅ Profile updated successfully`

## API Response Handling

The code handles multiple possible response formats:

- `{image_urls: [...]}`
- `{images: [...]}`
- `{urls: [...]}`
- `{imageUrls: [...]}`
- `[url1, url2, ...]` (array directly)

## Error Handling

Errors are logged with:

- Error message
- DioException response data (if available)
- HTTP status code (if available)

Example error output:

```
❌ Error uploading photos: DioException...
❌ Response data: {detail: "Invalid image format"}
❌ Status code: 400
```
