# 🔍 Registration Debug Logging - Enhanced!

## What Was Added

Enhanced logging in `ApiClient` to help debug registration issues.

## Changes Made

### Enhanced Request Logging

```dart
print('🌐 REQUEST[${options.method}] => ${options.uri}');
print('📋 Headers: ${options.headers}');
if (options.data != null) {
  print('📦 Data: ${options.data}');
}
print('🔓 Public Endpoint: $skipAuth');
```

### Enhanced Response Logging

```dart
print('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
print('📥 Response Data: ${response.data}');
```

### Enhanced Error Logging

```dart
print('❌ ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}');
print('❌ Error Response: ${error.response?.data}');
print('❌ Error Message: ${error.message}');
```

## What You'll See in Logs

### Successful Registration

```
🌐 REQUEST[POST] => http://10.0.2.2:7000/auth/users/
📋 Headers: {Content-Type: application/json, Accept: application/json}
📦 Data: {username: john_doe, email: john@university.edu, password: Test123!, re_password: Test123!, university: 1, gender: male, preferred_genders: [female], intent: dating, is_private: false}
🔓 Public Endpoint: true
✅ RESPONSE[201] => http://10.0.2.2:7000/auth/users/
📥 Response Data: {id: 1, username: john_doe, email: john@university.edu, ...}
```

### Failed Registration

```
🌐 REQUEST[POST] => http://10.0.2.2:7000/auth/users/
📋 Headers: {Content-Type: application/json, Accept: application/json}
📦 Data: {username: john_doe, email: john@university.edu, ...}
🔓 Public Endpoint: true
❌ ERROR[400] => http://10.0.2.2:7000/auth/users/
❌ Error Response: {email: [User with this email already exists.]}
❌ Error Message: Http status error [400]
```

## Registration Data Sent

The registration now sends:

```json
{
  "username": "john_doe",
  "email": "john@university.edu",
  "password": "Test123!",
  "re_password": "Test123!",  ← Added for confirmation
  "university": 1,
  "gender": "male",
  "preferred_genders": ["female"],
  "intent": "dating",
  "is_private": false  ← Added default value
}
```

## Headers Verification

The ApiClient automatically sets:

```dart
BaseOptions(
  headers: {
    'Content-Type': 'application/json',  ← Already set
    'Accept': 'application/json',
  },
)
```

## JSON Encoding

Dio automatically handles JSON encoding:

- When you pass a `Map<String, dynamic>` to `data`
- Dio converts it to JSON string
- Sets Content-Type to application/json
- No need for manual `jsonEncode()`

## How to Debug

### 1. Check Request Data

Look for the `📦 Data:` line to see what's being sent

### 2. Check Headers

Look for the `📋 Headers:` line to verify Content-Type

### 3. Check Public Endpoint

Look for the `🔓 Public Endpoint: true` to verify no token is sent

### 4. Check Error Response

Look for the `❌ Error Response:` line to see backend error details

## Common Issues & Solutions

### Issue: "email already exists"

```
❌ Error Response: {email: [User with this email already exists.]}
```

**Solution:** User already registered, try different email

### Issue: "password too short"

```
❌ Error Response: {password: [This password is too short.]}
```

**Solution:** Use stronger password (8+ characters)

### Issue: "university not found"

```
❌ Error Response: {university: [Invalid pk "999" - object does not exist.]}
```

**Solution:** Verify university ID exists in database

### Issue: "invalid gender"

```
❌ Error Response: {gender: ["male" is not a valid choice.]}
```

**Solution:** Check backend accepts "male", "female", etc.

### Issue: "preferred_genders required"

```
❌ Error Response: {preferred_genders: [This field is required.]}
```

**Solution:** Already included in request

## Testing Registration

1. Open app
2. Fill registration form
3. Complete onboarding
4. Click "Start Exploring"
5. Check console logs for:
   - Request data
   - Headers
   - Response/Error

## What to Look For

### ✅ Good Signs

- `🔓 Public Endpoint: true`
- `Content-Type: application/json` in headers
- `✅ RESPONSE[201]` for successful creation
- Response data contains user object

### ❌ Problem Signs

- `❌ ERROR[400]` - Validation error (check error response)
- `❌ ERROR[401]` - Should not happen for registration
- `❌ ERROR[500]` - Backend server error
- Missing `Content-Type` header
- `🔓 Public Endpoint: false` (should be true)

## Summary

✅ **Enhanced logging** for debugging
✅ **Headers logged** to verify Content-Type
✅ **Full error responses** shown
✅ **Public endpoint** verification
✅ **Request/response data** visible

Now you can see exactly what's being sent and what errors the backend returns! 🔍
