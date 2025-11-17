# Error Handling Improvements

## Overview
Enhanced error handling to provide user-friendly messages and automatically handle invalid tokens.

## Changes Made

### 1. Enhanced Custom Snackbar
**File:** `lib/core/widgets/custom_snackbar.dart`

**Features:**
- ✅ Title + message format (e.g., "Error" + detailed message)
- ✅ Icon with circular background
- ✅ Better colors (Material Design 3 colors)
- ✅ Rounded corners (16px)
- ✅ Auto-clear previous snackbars
- ✅ Optional action button
- ✅ Longer duration (4 seconds)

**Usage:**
```dart
CustomSnackbar.show(
  context,
  message: 'This username is already taken',
  type: SnackbarType.error,
);
```

### 2. Field-Specific Error Parsing
**File:** `lib/core/network/api_client.dart`

**Added Methods:**
- `_parseFieldErrors()` - Extracts field-specific errors from API response
- `_getUserFriendlyMessage()` - Converts technical errors to user-friendly messages

**Supported Fields:**
- `username` - "This username is already taken. Please try a different name."
- `email` - "An account with this email already exists. Please login instead."
- `password` - "Password must be at least 8 characters long."
- `re_password` - "Passwords do not match."

**Example API Error:**
```json
{
  "username": ["A user with that username already exists."]
}
```

**Converted to:**
```
"This username is already taken. Please try a different name."
```

### 3. Automatic Token Cleanup on 401
**File:** `lib/core/network/api_client.dart`

**Behavior:**
When receiving a 401 error with "user not found":
1. Automatically clears all tokens
2. Logs the action
3. User is redirected to login by splash screen

**Code:**
```dart
if (errorData['code'] == 'user_not_found') {
  print('🔒 User not found - clearing tokens');
  await clearTokens();
  return handler.next(error);
}
```

### 4. Improved 401 Error Messages
**File:** `lib/core/network/api_client.dart`

**Messages:**
- User not found: "Your account was not found. Please register again."
- Token expired: "Session expired. Please login again."
- Other 401: Uses API's detail message

## Error Flow

### Registration with Existing Username

```
1. User submits registration form
2. API returns 400 with:
   {
     "username": ["A user with that username already exists."]
   }
3. ApiClient parses error
4. Converts to: "This username is already taken. Please try a different name."
5. Returns ValidationFailure with friendly message
6. UI shows CustomSnackbar with error
```

### Invalid Token (User Not Found)

```
1. App starts with stored token
2. Tries to fetch user: GET /auth/users/me/
3. API returns 401 with:
   {
     "detail": "User not found",
     "code": "user_not_found"
   }
4. ApiClient detects "user_not_found"
5. Automatically clears tokens
6. Splash screen redirects to login
7. User sees: "Your account was not found. Please register again."
```

### Token Expired

```
1. User makes authenticated request
2. API returns 401 (token expired)
3. ApiClient attempts token refresh
4. If refresh succeeds: Retries original request
5. If refresh fails: Clears tokens and shows error
6. User redirected to login
```

## User-Friendly Error Messages

### Before
```
❌ "A user with that username already exists."
❌ "This field may not be blank."
❌ "Authentication credentials were not provided."
```

### After
```
✅ "This username is already taken. Please try a different name."
✅ "Please enter a valid email address."
✅ "Session expired. Please login again."
```

## Testing

### Test Username Already Exists
1. Register with name "John Doe"
2. Try to register again with same name
3. Should see: "This username is already taken. Please try a different name."

### Test Email Already Exists
1. Register with email "test@example.com"
2. Try to register again with same email
3. Should see: "An account with this email already exists. Please login instead."

### Test Invalid Token
1. Login successfully
2. Delete user from backend database
3. Restart app
4. Should automatically clear tokens and redirect to login
5. Should see: "Your account was not found. Please register again."

### Test Token Expired
1. Login successfully
2. Wait for token to expire (or manually expire it)
3. Make any authenticated request
4. Should automatically refresh token and retry
5. If refresh fails, should redirect to login

## Benefits

✅ **Better UX** - Users see clear, actionable error messages
✅ **Automatic Recovery** - Invalid tokens are automatically cleared
✅ **Consistent Design** - All errors use the same snackbar style
✅ **Developer Friendly** - Easy to add new error mappings
✅ **Secure** - Tokens are cleared when user doesn't exist

## Future Enhancements

- [ ] Add more field-specific error mappings
- [ ] Support for multiple errors at once
- [ ] Localization support for error messages
- [ ] Retry mechanism for network errors
- [ ] Offline mode detection
