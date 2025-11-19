# Adding Progress Indicators to Onboarding Pages

## Quick Guide

For each onboarding page, add the progress indicator at the top of the body.

### Step 1: Import the widget

```dart
import '../../../../core/widgets/onboarding_progress.dart';
```

### Step 2: Add to the page

```dart
body: SafeArea(
  child: Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ADD THIS:
              const OnboardingProgress(currentStep: X, totalSteps: 8),
              SizedBox(height: 24.h),
              // Rest of your content...
            ],
          ),
        ),
      ),
    ],
  ),
),
```

## Pages to Update

### ✅ Already Updated
- [x] University Selection (Step 1/8) - 12.5%
- [x] Gender (Step 2/8) - 25%
- [x] Photos (Step 7/8) - 87.5%

### ⏳ Need to Update

#### 1. Gender Preference Page
**File:** `lib/features/onboarding/presentation/pages/onboarding_gender_preference_page.dart`
**Step:** 3/8 (37.5%)
```dart
const OnboardingProgress(currentStep: 3, totalSteps: 8),
```

#### 2. Intent Page
**File:** `lib/features/onboarding/presentation/pages/onboarding_intent_page.dart`
**Step:** 4/8 (50%)
```dart
const OnboardingProgress(currentStep: 4, totalSteps: 8),
```

#### 3. Bio Page
**File:** `lib/features/onboarding/presentation/pages/profile/onboarding_bio_page.dart`
**Step:** 5/8 (62.5%)
```dart
const OnboardingProgress(currentStep: 5, totalSteps: 8),
```

#### 4. Course & Graduation Page
**File:** `lib/features/onboarding/presentation/pages/profile/onboarding_course_page.dart`
**Step:** 6/8 (75%)
```dart
const OnboardingProgress(currentStep: 6, totalSteps: 8),
```

#### 5. Date of Birth Page
**File:** `lib/features/onboarding/presentation/pages/profile/onboarding_dob_page.dart`
**Step:** 8/8 (100%)
```dart
const OnboardingProgress(currentStep: 8, totalSteps: 8),
```

#### 6. Interests Page (Optional)
**File:** `lib/features/onboarding/presentation/pages/onboarding_interests_page.dart`
**Note:** This is after DOB, so it's technically "bonus" content
```dart
const OnboardingProgress(currentStep: 8, totalSteps: 8), // Keep at 100%
```

## Example: Gender Preference Page

### Before:
```dart
body: SafeArea(
  child: Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Interested in',
                style: appStyle(32, Colors.black, FontWeight.w900),
              ),
              // ...
            ],
          ),
        ),
      ),
    ],
  ),
),
```

### After:
```dart
body: SafeArea(
  child: Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OnboardingProgress(currentStep: 3, totalSteps: 8),
              SizedBox(height: 24.h),
              Text(
                'Interested in',
                style: appStyle(32, Colors.black, FontWeight.w900),
              ),
              // ...
            ],
          ),
        ),
      ),
    ],
  ),
),
```

## Testing

After adding progress indicators:
1. Run the app
2. Go through onboarding flow
3. Verify progress bar increases on each page
4. Verify percentage shows correctly
5. Verify "Step X of 8" updates

## Notes

- Progress indicator is responsive (uses ScreenUtil)
- Shows linear progress bar with percentage
- Shows step counter and remaining steps
- Black progress bar matches app theme
- Automatically calculates percentage from currentStep/totalSteps
