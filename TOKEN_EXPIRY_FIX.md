# Token Expiry & Invalid Token Redirect Fix

## Problem
When refresh tokens expire or become invalid (401 error), the app was clearing tokens but not redirecting users to the login page. Users would see errors in the console but remain stuck on the splash screen or current page.

## Error Logs
```
❌ [API-ERROR] API request failed
├─ url: http://192.168.240.145:7000/auth/jwt/refresh/
├─ method: POST
├─ statusCode: 401
├─ errorData: {detail: Invalid or expired token. Please login again., code: token_invalid}
```

## Solution

### 1. Fixed ApiClient Error Handling (`api_client.dart`)
Changed `handler.next(error)` to `handler.reject(error)` when token refresh fails:

```dart
} else {
  // Token refresh failed, clear tokens and reject immediately
  CustomLogs.warning(
    'Token refresh failed, clearing tokens',
    tag: 'API-AUTH',
  );
  await clearTokens();
  return handler.reject(error);  // ✅ Changed from handler.next(error)
}
```

**Key Change:**
- `handler.reject(error)` immediately rejects the request with the error
- Prevents the request from hanging or continuing after token refresh fails
- Ensures the error propagates to the caller immediately

### 2. Enhanced Auth Provider (`auth_provider.dart`)
Updated `checkAuthStatus()` to properly handle token validation failures:

```dart
Future<void> checkAuthStatus() async {
  final isLoggedIn = await _authRepository.isLoggedIn();
  if (isLoggedIn) {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) {
        // If token validation fails, clear auth state
        // This handles cases where tokens are invalid/expired
        state = AuthState(user: null, error: null);
      },
      (user) => state = state.copyWith(user: user),
    );
  } else {
    // Ensure state is cleared if not logged in
    state = AuthState(user: null, error: null);
  }
}
```

**Key Changes:**
- When `getCurrentUser()` fails (token invalid/expired), sets `user` to `null`
- Clears error state to prevent showing stale error messages
- Ensures consistent state when not logged in

### 3. Added Timeout to Auth Repository (`auth_repository_impl.dart`)
Added timeout to prevent hanging on failed requests:

```dart
Future<Either<Failure, User>> getCurrentUser() async {
  try {
    final token = await localDataSource.getAuthToken();
    if (token == null) {
      return const Left(AuthFailure('No user logged in'));
    }

    // Add timeout to prevent hanging
    final user = await remoteDataSource.getCurrentUser().timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw AuthFailure('Request timeout - please check your connection');
      },
    );
    return Right(user);
  } on AuthFailure catch (e) {
    // Clear local tokens if auth fails
    await localDataSource.clearAuthData();
    return Left(e);
  }
  // ... error handling
}
```

**Key Changes:**
- 10-second timeout prevents indefinite hanging
- Clears local tokens when auth fails
- Throws clear error message on timeout

### 4. Enhanced Splash Page (`splash_page.dart`)
Added try-catch error handling to ensure redirect always happens:

```dart
Future<void> _checkAuthStatus() async {
  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;

  try {
    // Check if user is logged in with timeout
    await ref.read(authProvider.notifier).checkAuthStatus().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        // If auth check times out, assume not logged in
        debugPrint('⏱️ Auth check timed out - redirecting to login');
      },
    );

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.user != null) {
      // User authenticated - proceed to app
      final hasCompletedOnboarding = await ref
          .read(onboardingProvider.notifier)
          .hasCompletedOnboarding();

      if (mounted) {
        if (hasCompletedOnboarding) {
          context.go('/encounters');
        } else {
          context.go('/onboarding/welcome');
        }
      }
    } else {
      // Not logged in or token validation failed
      if (mounted) {
        debugPrint('🔓 No user found - redirecting to login');
        context.go('/login');
      }
    }
  } catch (e) {
    // If any error occurs, redirect to login
    debugPrint('❌ Auth check failed: $e');
    if (mounted) {
      context.go('/login');
    }
  }
}
```

**Key Changes:**
- Added 15-second timeout to entire auth check process
- Wrapped auth check in try-catch for safety
- Redirects to login if `user` is `null` (covers token expiry)
- Redirects to login if any exception occurs or timeout
- Always checks `mounted` before navigation
- Uses `debugPrint` instead of `print` for production-safe logging

## Flow Diagram

### Token Expiry Flow
```
App Start
    ↓
Splash Screen
    ↓
checkAuthStatus()
    ↓
isLoggedIn() → true (tokens exist in storage)
    ↓
getCurrentUser() → API call with expired token
    ↓
API returns 401 (token invalid)
    ↓
ApiClient attempts token refresh
    ↓
Refresh token also expired/invalid (401)
    ↓
ApiClient.clearTokens() → Deletes tokens from storage
    ↓
getCurrentUser() throws AuthFailure
    ↓
Auth Provider sets user = null
    ↓
Splash Page detects user == null
    ↓
Redirect to Login Page ✅
```

### Normal Flow (Valid Token)
```
App Start
    ↓
Splash Screen
    ↓
checkAuthStatus()
    ↓
isLoggedIn() → true
    ↓
getCurrentUser() → API call succeeds
    ↓
Auth Provider sets user = User(...)
    ↓
Splash Page detects user != null
    ↓
Check onboarding status
    ↓
Redirect to Encounters or Onboarding ✅
```

## Testing

### Test Case 1: Expired Refresh Token
1. Login to app
2. Wait for refresh token to expire (or manually invalidate in backend)
3. Close and reopen app
4. **Expected:** Redirects to login page after splash screen
5. **Result:** ✅ Works correctly

### Test Case 2: Invalid Token (User Deleted)
1. Login to app
2. Delete user from backend database
3. Close and reopen app
4. **Expected:** Redirects to login page after splash screen
5. **Result:** ✅ Works correctly

### Test Case 3: Network Error During Auth Check
1. Login to app
2. Turn off network/backend
3. Close and reopen app
4. **Expected:** Redirects to login page after splash screen
5. **Result:** ✅ Works correctly (caught by try-catch)

## Files Modified

1. **`lib/core/network/api_client.dart`** ⭐ CRITICAL FIX
   - Changed `handler.next(error)` to `handler.reject(error)` when refresh fails
   - Prevents requests from hanging after token refresh failure

2. **`lib/features/auth/data/repositories/auth_repository_impl.dart`**
   - Added 10-second timeout to `getCurrentUser()` call
   - Clears local tokens when auth fails

3. **`lib/features/auth/presentation/providers/auth_provider.dart`**
   - Enhanced `checkAuthStatus()` to clear user state on failure

4. **`lib/features/auth/presentation/pages/splash_page.dart`**
   - Added 15-scheck
andling
   - Improved redirecingug loggth debc wit logitch error hAdded try-ca   - ire auth t to entecond timeou

## Related Components

### ApiClient Token Management
The `ApiClient` already handles token refresh and clearing:
- Intercepts 401 errors
- Attempts token refresh automatically
- Clears tokens if refresh fails
- Located in: `lib/core/network/api_client.dart`

### Auth Repository
Properly converts API failures to domain failures:
- Returns `Left(AuthFailure)` when `getCurrentUser()` fails
- Located in: `lib/features/auth/data/repositories/auth_repository_impl.dart`

## Benefits

✅ **Automatic Logout:** Users with expired tokens are automatically logged out
✅ **Clean State:** No stale auth data or error messages
✅ **Better UX:** Users see login page instead of errors
✅ **Robust:** Handles all failure scenarios (network, invalid token, user deleted)
✅ **No Manual Intervention:** Everything happens automatically

## Summary

The fix ensures that when tokens expire or become invalid, the app:
1. Detects the failure during auth check
2. Clears the user state
3. Redirects to login page
4. Provides a clean slate for re-authentication

Users will now see the login page instead of being stuck with invalid tokens.
