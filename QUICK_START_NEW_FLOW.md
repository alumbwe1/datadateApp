# 🚀 Quick Start - New Registration Flow

## What Changed?

The registration flow now has **independent pages** for each step with **better password validation** and **improved error handling**.

## Flow Overview

```
Register → Gender → University → Gender Preference → Intent → 
Bio → Course → Graduation → Age → Interests → Complete → Home
```

## Testing the New Flow

### 1. Run the App
```bash
flutter pub get
flutter run
```

### 2. Start Registration
- Open app
- Click "Sign Up"

### 3. Fill Registration Form
```
Name: John Doe
Email: john@mit.edu
Password: Test123 ❌ (will fail - too common)
Password: john123 ❌ (will fail - similar to email)
Password: SecurePass123 ✅ (will pass)
Confirm Password: SecurePass123
```

### 4. Complete Onboarding Steps

**Gender Selection**
- Select: Male

**University Selection**
- Search and select: MIT

**Gender Preference**
- Select: Women

**Intent Selection**
- Select: Dating

**Bio**
- Write at least 20 characters
- Example: "Love hiking, coffee, and good conversations. Looking for someone to explore the city with."

**Course**
- Enter: Computer Science
- Or select from popular courses

**Graduation Year**
- Select: 2026

**Age**
- Enter: 21 (must be 18+)

**Interests**
- Select up to 5 interests
- Example: hiking, coffee, coding, AI, music

### 5. Complete Registration
- Click "Start Exploring"
- User is registered with API
- Auto-logged in
- Profile updated
- Navigated to home

## Password Validation

The password must:
- ✅ Be at least 8 characters long
- ✅ Not be entirely numeric
- ✅ Not be too common (e.g., "password123")
- ✅ Not be similar to email or username

### Common Passwords (Rejected)
- password, password123
- 12345678, qwerty
- abc123, letmein
- welcome, monkey
- 1234567890, password1

### Good Passwords (Accepted)
- SecurePass123
- MyP@ssw0rd!
- DataDate2024
- Hiking&Coffee

## Error Handling

### Password Errors
When password validation fails, a **bottom sheet** appears showing:
- ❌ Error icon
- 📝 Clear error message
- ✅ List of requirements
- 🔄 "Try Again" button

### API Errors
- Network errors → Snackbar
- Validation errors → Snackbar
- Password API errors → Bottom sheet
- Missing data → Redirect to register

## API Integration

### Registration API Call
```json
POST /auth/users/
{
  "username": "john_doe",
  "email": "john@mit.edu",
  "password": "SecurePass123",
  "re_password": "SecurePass123",
  "university": 3,
  "gender": "male",
  "preferred_genders": ["female"],
  "intent": "dating",
  "is_private": false
}
```

### Profile Update API Call
```json
PATCH /api/profiles/me/
{
  "bio": "Love hiking and coffee...",
  "course": "Computer Science",
  "date_of_birth": "2003-01-01",
  "graduation_year": 2026,
  "interests": ["hiking", "coffee", "coding", "AI", "music"]
}
```

## Troubleshooting

### Password Validation Fails
- Check if password is at least 8 characters
- Check if password contains email username
- Check if password is in common passwords list
- Try a more unique password

### Registration Fails
- Check backend is running
- Check API_BASE_URL is correct
- Check network connection
- Check backend logs for errors

### Profile Update Fails
- Check if user is logged in
- Check if auth token is valid
- Check if all required fields are filled
- Check backend logs for errors

## Next Steps

1. **Customize Validation**
   - Edit `lib/core/utils/validators.dart`
   - Add more password rules
   - Add more field validations

2. **Add More Options**
   - Edit interest lists
   - Add more courses
   - Add more intents

3. **Enhance UI**
   - Customize colors
   - Add animations
   - Add illustrations

4. **Add Features**
   - Profile photo upload
   - Email verification
   - Phone verification
   - Social login

## Files to Check

### New Files
- `lib/features/onboarding/presentation/pages/onboarding_gender_page.dart`
- `lib/features/onboarding/presentation/pages/onboarding_intent_page.dart`
- `lib/features/onboarding/presentation/pages/profile/onboarding_bio_page.dart`
- `lib/features/onboarding/presentation/pages/profile/onboarding_course_page.dart`
- `lib/features/onboarding/presentation/pages/profile/onboarding_graduation_page.dart`
- `lib/features/onboarding/presentation/pages/profile/onboarding_age_page.dart`
- `lib/core/widgets/password_error_bottom_sheet.dart`

### Updated Files
- `lib/features/auth/presentation/pages/register_page.dart`
- `lib/features/onboarding/presentation/providers/onboarding_provider.dart`
- `lib/features/onboarding/presentation/pages/onboarding_complete_page.dart`
- `lib/core/utils/validators.dart`
- `lib/core/router/app_router.dart`

## Support

For more details, see:
- `NEW_REGISTRATION_FLOW.md` - Complete documentation
- `API_DATA_FORMATS.md` - API request/response formats
- `ONBOARDING_FLOW.md` - Original onboarding flow

## Summary

✅ Registration flow redesigned with independent pages
✅ Better password validation with clear requirements
✅ Password errors shown in bottom sheet
✅ All data collected before API call
✅ Registration happens at the end
✅ Auto-login after registration
✅ Profile updated with collected data
✅ Seamless navigation to home

**The flow is ready to use! Just run the app and test it out.** 🎉
