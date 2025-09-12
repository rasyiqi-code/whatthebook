# Firebase Authentication Setup Guide

This guide will help you set up Firebase authentication with Google Sign-In for the Alhuda Library app.

## Prerequisites

1. A Google account
2. Access to the [Firebase Console](https://console.firebase.google.com/)
3. Flutter development environment set up

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter your project name (e.g., "alhuda-library-app")
4. Choose whether to enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Enable Authentication

1. In your Firebase project, go to "Authentication" in the left sidebar
2. Click "Get started"
3. Go to the "Sign-in method" tab
4. Enable "Google" as a sign-in provider
5. Add your project's support email
6. Save the configuration

## Step 3: Configure Android App

1. In Firebase Console, click "Add app" and select Android
2. Enter your Android package name: `com.crediblemark.whatthebook`
3. Enter app nickname (optional): "Alhuda Library Android"
4. Download the `google-services.json` file
5. Replace the placeholder file at `android/app/google-services.json` with your downloaded file

## Step 4: Configure iOS App (Optional)

1. In Firebase Console, click "Add app" and select iOS
2. Enter your iOS bundle ID: `com.crediblemark.whatthebook`
3. Enter app nickname (optional): "Alhuda Library iOS"
4. Download the `GoogleService-Info.plist` file
5. Add it to your iOS project in Xcode

## Step 5: Update Firebase Configuration

1. Install the Firebase CLI: `npm install -g firebase-tools`
2. Login to Firebase: `firebase login`
3. Configure FlutterFire: `dart pub global activate flutterfire_cli`
4. Run FlutterFire configure: `flutterfire configure`
5. Select your Firebase project
6. Select platforms (Android, iOS, etc.)
7. This will generate/update the `lib/firebase_options.dart` file

## Step 6: Configure Supabase for Firebase Auth

1. Go to your Supabase project dashboard
2. Navigate to Authentication > Providers
3. Enable "Firebase" as a third-party provider
4. Add your Firebase project configuration:
   - Project ID: Your Firebase project ID
   - Private Key: Your Firebase service account private key
   - Client Email: Your Firebase service account email

### Getting Firebase Service Account Key

1. Go to Firebase Console > Project Settings > Service Accounts
2. Click "Generate new private key"
3. Download the JSON file
4. Use the values from this file in your Supabase configuration

## Step 7: Test the Implementation

1. Run `flutter pub get` to install dependencies
2. Run the app: `flutter run`
3. Try signing in with Google
4. Check that the user is created in both Firebase and Supabase

## Troubleshooting

### Common Issues

1. **SHA-1 fingerprint issues**: Make sure to add your debug and release SHA-1 fingerprints to Firebase
   ```bash
   # Get debug SHA-1
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

2. **Google Sign-In not working**: Ensure you've added the correct SHA-1 fingerprints and package name

3. **Supabase integration issues**: Verify that your Firebase service account key is correctly configured in Supabase

### Debug Steps

1. Check Firebase Console for authentication events
2. Check Supabase dashboard for user creation
3. Use Flutter's debug console to see error messages
4. Verify all configuration files are in place

## Security Notes

- Never commit your `google-services.json` or `GoogleService-Info.plist` files to public repositories
- Use environment variables for sensitive configuration in production
- Regularly rotate your Firebase service account keys
- Enable Firebase Security Rules for additional protection

## Additional Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Supabase Third-party Auth](https://supabase.com/docs/guides/auth/third-party)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
