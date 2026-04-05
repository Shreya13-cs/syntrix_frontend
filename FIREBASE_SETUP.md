# Firebase Setup Instructions for Sanctuary App

## Overview
The Sanctuary app includes Login and Sign Up screens with Firebase Authentication integration.

## What's Been Created

1. **Login Screen** (`lib/screens/login_screen.dart`)
   - Email/password authentication
   - Password visibility toggle
   - Forgot password link
   - Navigation to sign up screen
   - Security badges

2. **Sign Up Screen** (`lib/screens/signup_screen.dart`)
   - Full name, email, and password fields
   - Password validation (minimum 8 characters)
   - Google Sign-In integration
   - Apple Sign-In placeholder
   - Navigation to login screen

3. **Firebase Configuration** (`lib/firebase_options.dart`)
   - Platform-specific Firebase options
   - Needs to be configured with your actual Firebase credentials

## Setup Steps

### 1. Install Dependencies
Run the following command to install all required packages:
```bash
flutter pub get
```

### 2. Configure Firebase

You have a Firebase service account JSON file: `syntrix-430f9-firebase-adminsdk-fbsvc-ca084b7c96.json`

To properly configure Firebase for your Flutter app:

#### Option A: Using FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=syntrix-430f9
```

This will automatically generate the correct `firebase_options.dart` file with all platform configurations.

#### Option B: Manual Configuration
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `syntrix-430f9`
3. Add apps for each platform you want to support:
   - **Android**: Download `google-services.json` → place in `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` → place in `ios/Runner/`
   - **Web**: Copy the Firebase config and update `lib/firebase_options.dart`

4. Update `lib/firebase_options.dart` with your actual API keys and app IDs

### 3. Enable Authentication Methods

1. Go to Firebase Console → Authentication → Sign-in method
2. Enable the following:
   - **Email/Password**: Enable this for basic authentication
   - **Google**: Enable and configure OAuth consent screen
   - **Apple**: Enable if you want Apple Sign-In (iOS only)

### 4. Configure Google Sign-In (Optional)

For Android:
1. Add SHA-1 fingerprint to Firebase project
2. Download updated `google-services.json`

For iOS:
1. Add URL schemes to `Info.plist`
2. Configure OAuth client ID

### 5. Platform-Specific Setup

#### Android (`android/app/build.gradle`)
Add at the bottom of the file:
```gradle
apply plugin: 'com.google.gms.google-services'
```

And in `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

#### iOS
No additional setup required if using FlutterFire CLI.

### 6. Run the App
```bash
flutter run
```

## Features Implemented

- ✅ Email/Password Authentication
- ✅ User Registration with display name
- ✅ Google Sign-In integration
- ✅ Password visibility toggle
- ✅ Form validation
- ✅ Error handling with user-friendly messages
- ✅ Loading states
- ✅ Responsive UI matching the design mockups

## Design Details

- **Color Scheme**: Teal/Sanctuary green (#2D7A7B)
- **Typography**: Clean, modern sans-serif
- **UI Elements**: Rounded corners, subtle shadows, minimal design
- **Icons**: Material Icons for consistency

## Next Steps

1. Configure Firebase with actual credentials
2. Test authentication flows
3. Add password reset functionality
4. Implement home screen after successful login
5. Add user profile management
6. Set up Firestore for user data storage

## Troubleshooting

- If you get Firebase initialization errors, ensure `firebase_options.dart` has correct values
- For Google Sign-In issues, verify SHA-1 fingerprint is added to Firebase
- Make sure Firebase Authentication is enabled in the console
