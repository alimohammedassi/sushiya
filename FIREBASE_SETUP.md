# Firebase Setup Guide for Sushiaya

## ✅ What's Already Configured

I've already set up the basic Firebase configuration for your Flutter app:

### 1. **Gradle Configuration**
- ✅ Added Google Services plugin to `android/build.gradle.kts`
- ✅ Added Firebase plugin to `android/app/build.gradle.kts`
- ✅ Added Firebase BoM and Analytics dependency

### 2. **Flutter Dependencies**
- ✅ Added Firebase packages to `pubspec.yaml`:
  - `firebase_core: ^3.6.0`
  - `firebase_analytics: ^11.3.10`
  - `firebase_auth: ^5.3.3`
  - `cloud_firestore: ^5.4.5`
  - `firebase_storage: ^12.3.3`

### 3. **Code Integration**
- ✅ Updated `lib/main.dart` to initialize Firebase
- ✅ Created `lib/firebase_options.dart` (placeholder)
- ✅ Created `lib/services/firebase_service.dart` with helper methods

## 🔧 Next Steps to Complete Setup

### Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 2: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name it "Sushiaya" or your preferred name
4. Follow the setup wizard

### Step 3: Add Android App to Firebase
1. In Firebase Console, click "Add app" → Android
2. Use package name: `com.example.sushiaya`
3. Download the `google-services.json` file
4. Place it in `android/app/google-services.json`

### Step 4: Generate Firebase Configuration
```bash
flutterfire configure
```
This will:
- Update `lib/firebase_options.dart` with real configuration
- Add iOS configuration if needed
- Set up web configuration if needed

### Step 5: Install Dependencies
```bash
flutter pub get
```

### Step 6: Test Firebase Connection
Run the app and check the console for Firebase initialization messages.

## 🚀 Firebase Features Available

### Authentication
```dart
// Sign in
await FirebaseService.signInWithEmailAndPassword(email, password);

// Sign up
await FirebaseService.createUserWithEmailAndPassword(email, password);

// Sign out
await FirebaseService.signOut();
```

### Firestore Database
```dart
// Add user data
await FirebaseService.addUserData(userId, userData);

// Add order
await FirebaseService.addOrder(orderData);

// Get orders stream
Stream<QuerySnapshot> ordersStream = FirebaseService.getOrdersStream();
```

### Analytics
```dart
// Log custom events
await FirebaseService.logEvent(
  name: 'item_viewed',
  parameters: {'item_id': 'sushi_1', 'category': 'sushi'},
);

// Log purchases
await FirebaseService.logPurchase(
  currency: 'USD',
  value: 12.99,
  itemId: 'sushi_1',
  itemName: 'Salmon Roll',
);
```

### Storage
```dart
// Upload image
String? downloadUrl = await FirebaseService.uploadImage(
  'menu/sushi_1.jpg',
  imageBytes,
);

// Delete image
await FirebaseService.deleteImage('menu/sushi_1.jpg');
```

## 📱 Platform-Specific Setup

### Android
- ✅ Gradle configuration complete
- ⏳ Need `google-services.json` file

### iOS (if needed)
1. Add iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Add to iOS project
4. Update iOS configuration

### Web (if needed)
1. Add web app in Firebase Console
2. Update web configuration in `firebase_options.dart`

## 🔒 Security Rules

Don't forget to set up Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Anyone can read menu items
    match /menu/{document} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Users can create orders
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🎯 Next Development Steps

1. **Authentication UI**: Create login/signup screens
2. **User Profile**: Store user data in Firestore
3. **Order Management**: Save orders to Firestore
4. **Menu Management**: Store menu items in Firestore
5. **Image Upload**: Use Firebase Storage for menu images
6. **Analytics**: Track user behavior and purchases

## 🐛 Troubleshooting

### Common Issues:
1. **"google-services.json not found"**: Make sure the file is in `android/app/`
2. **"Firebase not initialized"**: Check `main.dart` initialization
3. **"Permission denied"**: Check Firestore security rules
4. **"Network error"**: Check internet connection and Firebase project settings

### Debug Commands:
```bash
# Check Firebase configuration
flutterfire configure --help

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📞 Support

If you encounter issues:
1. Check Firebase Console for error logs
2. Verify all configuration files are in place
3. Ensure dependencies are properly installed
4. Check Flutter and Firebase documentation

---

**Happy coding! 🍣 Your Sushiaya app is now ready for Firebase integration!**
