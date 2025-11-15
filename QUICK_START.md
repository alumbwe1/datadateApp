# 🚀 Quick Start - Real API Integration

## 3 Steps to Get Started

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Start Your Backend
Make sure your Django backend is running:
```bash
# In your backend directory
python manage.py runserver 0.0.0.0:8000
```

### Step 3: Run the App

**Option A: Use the Script (Easiest)**
```bash
# Double-click: run_with_api.bat
# Enter your API URL when prompted
```

**Option B: Command Line**
```bash
# Android Emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

# iOS Simulator  
flutter run --dart-define=API_BASE_URL=http://localhost:8000

# Physical Device (replace X with your IP)
flutter run --dart-define=API_BASE_URL=http://192.168.1.X:8000
```

## That's It! 🎉

Your app is now connected to the real API. Test it:

1. ✅ Register a new user
2. ✅ Login with credentials
3. ✅ Browse profiles
4. ✅ Swipe and like profiles
5. ✅ See matches

## Common URLs

| Environment | URL |
|-------------|-----|
| Android Emulator | `http://10.0.2.2:8000` |
| iOS Simulator | `http://localhost:8000` |
| Physical Device | `http://YOUR_IP:8000` |
| Production | `https://api.datadate.com` |

## Need Help?

- 📖 Full Guide: `API_INTEGRATION_GUIDE.md`
- 📋 Implementation Details: `REAL_API_INTEGRATION_COMPLETE.md`
- 🔍 Quick Reference: `API_QUICK_REFERENCE.md`
- 📊 Summary: `INTEGRATION_SUMMARY.md`

## Troubleshooting

**Can't connect?**
- Check backend is running
- Use correct URL for your platform
- Check firewall settings

**401 Errors?**
- Logout and login again
- Check backend JWT settings

**No profiles?**
- Add profiles to backend database
- Mock fallback should still work

---

**Everything is ready to go! Just start your backend and run the app.** 🚀
