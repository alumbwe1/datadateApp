# DataDate Onboarding Flow

## Complete Onboarding Journey

```
┌─────────────────────────────────────────────────────────────────┐
│                    ONBOARDING FLOW                              │
└─────────────────────────────────────────────────────────────────┘

1. Welcome Page (/onboarding)
   ├─ App logo & profile grid
   ├─ "Meet Campus Elite & Find Your Match"
   ├─ Create Account button → Register Page
   └─ Sign In link → Login Page

2. Register Page (/register)
   ├─ Name input
   ├─ Email input
   ├─ Password input
   ├─ Age input
   ├─ Gender selection (Male/Female)
   └─ Continue → Gender Preference Page

3. Gender Preference Page (/onboarding/gender-preference) ✨ NEW
   ├─ "Who would you like to date?"
   ├─ Options:
   │  ├─ 👨 Men
   │  ├─ 👩 Women
   │  └─ 🌈 Everyone
   └─ Continue → Traits Page

4. Traits Page (/onboarding/traits) ✨ NEW
   ├─ "What traits matter most to you?"
   ├─ Select at least 3 traits:
   │  ├─ 💖 Kind
   │  ├─ 🤝 Honest
   │  ├─ 😄 Funny
   │  ├─ 🧠 Intelligent
   │  ├─ 🎨 Creative
   │  ├─ 💪 Ambitious
   │  ├─ 🌟 Confident
   │  ├─ 🤗 Caring
   │  ├─ ✨ Adventurous
   │  ├─ 🎭 Spontaneous
   │  ├─ 📚 Educated
   │  ├─ 🏃 Active
   │  ├─ 🎵 Musical
   │  ├─ 🍳 Good Cook
   │  ├─ 💼 Career-Focused
   │  └─ 🌍 Traveler
   └─ Continue → Dating Goal Page

5. Dating Goal Page (/onboarding/dating-goal)
   ├─ "What brings you here?"
   ├─ Options:
   │  ├─ ☕ Here to date
   │  ├─ 💬 Open to chat
   │  └─ ❤️ Ready for a relationship
   └─ Continue → Interests Page

6. Interests Page (/onboarding/interests)
   ├─ "What are you into?"
   ├─ Select up to 5 interests:
   │  ├─ 🎮 Gaming
   │  ├─ 🎵 Music
   │  ├─ 📚 Reading
   │  ├─ ✈️ Travel
   │  ├─ 💪 Fitness
   │  ├─ 🍳 Cooking
   │  ├─ 📷 Photography
   │  ├─ 🎨 Art
   │  ├─ 🎬 Movies
   │  └─ 🏀 Sports
   └─ Continue → Complete Page

7. Complete Page (/onboarding/complete)
   ├─ Success animation
   ├─ "You're all set!"
   └─ Start Swiping → Encounters Page
```

## Data Collected

### User Profile Data
```dart
{
  name: String,
  email: String,
  password: String,
  age: int,
  gender: String,              // 'male' or 'female'
  genderPreference: String,    // 'male', 'female', or 'everyone'
  desiredTraits: List<String>, // min 3 traits
  datingGoal: String,          // 'date', 'chat', or 'relationship'
  interests: List<String>,     // up to 5 interests
  location: String,
}
```

## UI Features

### Gender Preference Page
- Clean card-based selection
- Large emoji icons (👨👩🌈)
- Animated selection states
- Black background on selected
- White checkmark indicator

### Traits Page
- Chip-based multi-selection
- Minimum 3 traits required
- Counter badge showing selection progress
- Emoji + text labels
- Animated selection with shadows
- Wrap layout for responsive design

### Design Patterns
- Consistent back navigation
- Haptic feedback on interactions
- Smooth animations (200ms)
- Black/white color scheme
- Rounded corners (16-24px)
- Progress indication
- Disabled state for Continue button until requirements met

## Navigation Flow

```
Welcome → Register → Gender Preference → Traits → Dating Goal → Interests → Complete → Encounters
   ↓                                                                                        ↑
 Login ────────────────────────────────────────────────────────────────────────────────────┘
```

## State Management

All onboarding data is managed by `OnboardingProvider` (Riverpod):
- Persists completion status to SharedPreferences
- Maintains state across page navigation
- Validates minimum requirements before allowing progression
- Clears state on logout

## Validation Rules

1. **Gender Preference**: Must select one option
2. **Traits**: Must select at least 3 traits
3. **Dating Goal**: Must select one option
4. **Interests**: Must select at least 1 interest (max 5)

## Future Enhancements

- [ ] Add location/university selection
- [ ] Photo upload step
- [ ] Bio writing step
- [ ] Email verification
- [ ] Skip options for non-critical steps
- [ ] Progress bar across all steps
- [ ] Save & continue later functionality
