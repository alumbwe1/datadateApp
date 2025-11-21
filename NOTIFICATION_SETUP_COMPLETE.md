# Notification Setup - Complete Implementation

## Overview

Implemented complete Firebase Cloud Messaging (FCM) integration with smart token management and background notification handling.

## Architecture

### 1. Main App Initialization (`lib/main.dart`)

**Initialization Flow:**

```
App Start
    ↓
Firebase.initializeApp()
    ↓
Register Background Message Handler
    ↓
Initialize Notifications (FCM)
    ↓
Update Device Info (if token changed)
    ↓
Run App
```

**Key Features:**

- Firebase initialization with error handling
- Background message handler registration
- FCM token initialization and backend sync
- Device info update (only if token changed)
- Comprehensive logging at each step

### 2. Notification Initializer (`lib/notification_initializer.dart`)

**Responsibilities:**

- Request notification permissions (iOS/Android)
- Get FCM token from Firebase
- Compare with stored token
- Send to backend only if changed
- Listen for token refresh events
- Set up local notifications
- Handle foreground messages

**API Integration:**

```dart
POST /auth/fcm-token/
{
  "fcm_token": "firebase_token_here"
}
```

**Token Change Detection:**

```dart
final storedToken = prefs.getString('fcmToken');
final currentToken = await messaging.getToken();

if (storedToken != currentToken) {
  // Token changed - update backend
  await _updateFcmTokenOnBackend(apiClient, currentToken);
  await prefs.setString('fcmToken', currentToken);
}
```

### 3. Device Info Updater (`lib/device_updator.dart`)

**Purpose:**

- Ensure FCM token is synced with backend
- Track last sent token to prevent duplicate updates
- Can be called on app resume or login

**Smart Update Logic:**

```dart
final fcmToken = prefs.getString('fcmToken');
final lastSentToken = prefs.getString('lastSentFcmToken');

if (lastSentToken != fcmToken) {
  // Token changed since last send - update backend
  await apiClient.post('/auth/fcm-token/', data: {'fcm_token': fcmToken});
  await prefs.setString('lastSentFcmToken', fcmToken);
}
```

## Notification Types

### 1. Foreground Notifications

**When:** App is open and in foreground
**Handling:** `FirebaseMessaging.onMessage.listen()`
**Action:** Show local notification using `flutter_local_notifications`

### 2. Background Notifications

**When:** App is in background or terminated
**Handling:** `_firebaseMessagingBackgroundHandler()`
**Action:** Process data, can't update UI directly

### 3. Notification Tap

**When:** User taps on notification
**Handling:** `onDidReceiveNotificationResponse`
**Action:** Navigate to relevant screen

## Message Structure

### Match Notification

```json
{
  "notification": {
    "title": "It's a Match! 🎉",
    "body": "You matched with Jane Smith!"
  },
  "data": {
    "type": "match",
    "match_id": "12",
    "user_id": "5",
    "user_name": "Jane Smith"
  }
}
```

### Like Notification

```json
{
  "notification": {
    "title": "New Like ❤️",
    "body": "Emily Wilson liked your profile!"
  },
  "data": {
    "type": "like",
    "like_id": "23",
    "liker_id": "7",
    "liker_name": "Emily Wilson"
  }
}
```

### Message Notification

```json
{
  "notification": {
    "title": "New Message 💬",
    "body": "Jane: Hey! How are you?"
  },
  "data": {
    "type": "message",
    "room_id": "3",
    "message_id": "156",
    "sender_id": "5"
  }
}
```

## Token Management Flow

### Initial Setup

```
1. App starts
2. Firebase initialized
3. Request notification permission
4. Get FCM token
5. Check if token exists in SharedPreferences
6. If new/changed:
   - Save to SharedPreferences ('fcmToken')
   - Send to backend (/auth/fcm-token/)
   - Save as last sent ('lastSentFcmToken')
```

### Token Refresh

```
1. Firebase detects token change
2. onTokenRefresh listener triggered
3. Compare with stored token
4. If different:
   - Update SharedPreferences ('fcmToken')
   - Send to backend (/auth/fcm-token/)
   - Update last sent ('lastSentFcmToken')
```

### App Resume

```
1. User opens app
2. DeviceInfoUpdater.updateFcmTokenIfChanged() called
3. Compare 'fcmToken' with 'lastSentFcmToken'
4. If different:
   - Send to backend (/auth/fcm-token/)
   - Update 'lastSentFcmToken'
```

## SharedPreferences Keys

| Key                | Purpose                         | Example Value  |
| ------------------ | ------------------------------- | -------------- |
| `fcmToken`         | Current FCM token from Firebase | `"dXYz123..."` |
| `lastSentFcmToken` | Last token sent to backend      | `"dXYz123..."` |

## Error Handling

### Firebase Initialization Failed

```dart
try {
  await Firebase.initializeApp();
} catch (e) {
  CustomLogs.error('Firebase initialization failed: $e');
  // App continues without notifications
}
```

### Token Retrieval Failed

```dart
try {
  final token = await messaging.getToken();
} catch (e) {
  print('❌ Error getting FCM token: $e');
  // Continue without token
}
```

### Backend Update Failed

```dart
try {
  await apiClient.post('/auth/fcm-token/', data: {'fcm_token': token});
} catch (e) {
  print('❌ Error updating FCM token on backend: $e');
  // Token saved locally, will retry on next app start
}
```

## Testing

### Test FCM Token Generation

1. Run app on device/emulator
2. Check logs for: `✅ FCM Token (new/updated): ...`
3. Verify token is sent to backend
4. Check backend logs for token receipt

### Test Token Refresh

1. Clear app data
2. Restart app
3. New token should be generated
4. Check logs for: `🔄 FCM Token refreshed: ...`

### Test Background Messages

1. Send test notification from Firebase Console
2. Put app in background
3. Verify notification appears
4. Check logs for: `📬 Background message received: ...`

### Test Foreground Messages

1. Keep app open
2. Send test notification
3. Verify local notification appears
4. Check logs for: `Foreground message received: ...`

## Configuration Files

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="datadate_channel" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

## Dependencies

```yaml
dependencies:
  firebase_core: ^4.2.1
  firebase_messaging: ^16.0.4
  flutter_local_notifications: ^18.0.1
  shared_preferences: ^2.3.2
```

## Best Practices Implemented

✅ **Token Change Detection**: Only update backend when token actually changes
✅ **Duplicate Prevention**: Track last sent token to avoid redundant API calls
✅ **Error Handling**: Graceful degradation if notifications fail
✅ **Logging**: Comprehensive logging with emojis for easy debugging
✅ **Background Handler**: Separate isolate for background messages
✅ **Local Notifications**: Show notifications when app is in foreground
✅ **Permission Handling**: Request permissions on iOS
✅ **Token Refresh**: Automatic handling of token refresh events

## Optimization Benefits

1. **Reduced API Calls**: Only send token when it changes
2. **Battery Efficient**: No unnecessary network requests
3. **Reliable**: Multiple checks ensure token is always synced
4. **Fast Startup**: Async initialization doesn't block UI
5. **Resilient**: Continues working even if one update fails

## Future Enhancements

- [ ] Add notification categories for different types
- [ ] Implement notification actions (reply, like back, etc.)
- [ ] Add notification sound customization
- [ ] Implement notification grouping
- [ ] Add notification analytics
- [ ] Support for rich media notifications (images, videos)
- [ ] Implement notification scheduling
- [ ] Add notification preferences screen

## Troubleshooting

### No Token Generated

- Check Firebase configuration
- Verify google-services.json (Android) or GoogleService-Info.plist (iOS)
- Ensure Firebase project has FCM enabled
- Check device has Google Play Services (Android)

### Token Not Sent to Backend

- Check network connectivity
- Verify API endpoint is correct
- Check authentication token is valid
- Review backend logs for errors

### Notifications Not Appearing

- Check notification permissions
- Verify notification channel is created (Android)
- Check device notification settings
- Review Firebase Console for delivery status

### Background Handler Not Working

- Ensure handler is top-level function
- Check @pragma annotation is present
- Verify Firebase is initialized in handler
- Review Android/iOS specific requirements

## Summary

The notification system is now fully implemented with:

- Smart FCM token management (only updates when changed)
- Background message handling
- Foreground notification display
- Comprehensive error handling
- Detailed logging for debugging
- Integration with backend API

Users will receive real-time notifications for matches, likes, and messages, with the system automatically managing token updates efficiently.
