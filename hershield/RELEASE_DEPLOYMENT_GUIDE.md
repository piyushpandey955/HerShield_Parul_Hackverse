# HerShield - Release APK Deployment Guide

## 🎉 Release Build Complete!

Your HerShield app has been successfully prepared for release distribution through your website.

---

## 📦 Release APK Location

**File:** `build/app/outputs/flutter-apk/app-release.apk`
**Size:** 55.1 MB
**Version:** 1.0.0+1

---

## 🔐 Security Features Implemented

### 1. **App Signing Configuration**
- ✅ Release keystore created: `~/upload-keystore.jks`
- ✅ Key properties configured in `android/key.properties`
- ✅ Signing credentials:
  - **Store Password:** hershield2025
  - **Key Password:** hershield2025
  - **Key Alias:** upload
  - **Validity:** 10,000 days

⚠️ **IMPORTANT:** Keep your keystore file (`upload-keystore.jks`) and `key.properties` file secure and backed up! You'll need them for all future updates.

### 2. **Code Obfuscation & Optimization**
- ✅ ProGuard/R8 minification enabled
- ✅ Resource shrinking enabled
- ✅ Debug print statements removed
- ✅ Code obfuscation rules configured

### 3. **App Metadata**
- ✅ App name: **HerShield**
- ✅ Package ID: `com.example.hershield`
- ✅ Version: 1.0.0 (Build 1)

---

## 🌐 Website Distribution Setup

### Step 1: Upload APK to Your Server

Upload the APK file to your web server:
```bash
# Example using SCP
scp build/app/outputs/flutter-apk/app-release.apk user@yourserver.com:/var/www/downloads/

# Or using FTP/SFTP client (FileZilla, Cyberduck, etc.)
```

### Step 2: Create Download Page

Create an HTML page with a download link:

```html
<!DOCTYPE html>
<html>
<head>
    <title>Download HerShield</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>Download HerShield</h1>
    <p>Women's Safety Companion App</p>
    
    <div>
        <h2>Version 1.0.0</h2>
        <p>Release Date: November 16, 2025</p>
        <p>Size: 55.1 MB</p>
        
        <a href="/downloads/app-release.apk" 
           download="HerShield-v1.0.0.apk"
           style="display: inline-block; padding: 15px 30px; 
                  background: #4CAF50; color: white; 
                  text-decoration: none; border-radius: 5px;">
            Download APK
        </a>
    </div>
    
    <div>
        <h3>Installation Instructions:</h3>
        <ol>
            <li>Download the APK file</li>
            <li>Enable "Install from Unknown Sources" in Settings</li>
            <li>Open the downloaded file</li>
            <li>Follow the installation prompts</li>
        </ol>
    </div>
</body>
</html>
```

### Step 3: Configure Server (Optional but Recommended)

Add to your `.htaccess` or server config:

```apache
# Force download APK files
<FilesMatch "\.apk$">
    Header set Content-Type "application/vnd.android.package-archive"
    Header set Content-Disposition "attachment"
</FilesMatch>
```

For Nginx:
```nginx
location ~* \.apk$ {
    add_header Content-Type application/vnd.android.package-archive;
    add_header Content-Disposition attachment;
}
```

---

## 📱 User Installation Instructions

Users who download from your website need to:

1. **Enable Unknown Sources:**
   - Go to Settings → Security
   - Enable "Unknown Sources" or "Install Unknown Apps"
   - Grant permission to the browser/file manager

2. **Download & Install:**
   - Click your download link
   - Open the downloaded APK
   - Tap "Install" and follow prompts

3. **Required Permissions:**
   HerShield requires these permissions:
   - ✓ Location (Fine & Coarse)
   - ✓ Background Location
   - ✓ Notifications
   - ✓ Microphone (for audio recording)
   - ✓ Camera
   - ✓ Storage (Read/Write)
   - ✓ Do Not Disturb access

---

## 🔄 Future Updates

### To release a new version:

1. **Update version in `pubspec.yaml`:**
   ```yaml
   version: 1.0.1+2  # Format: major.minor.patch+buildNumber
   ```

2. **Make your code changes**

3. **Rebuild the APK:**
   ```bash
   flutter clean
   flutter build apk --release
   ```

4. **Upload new APK** with version number in filename:
   - `HerShield-v1.0.1.apk`

5. **Update download page** with new version info

⚠️ **Important:** Always use the same keystore file to sign updates. Apps signed with different keys cannot update each other.

---

## 🔍 APK Verification

Users can verify the APK integrity using SHA-1 checksum:

```bash
# Generate SHA-1
sha1sum app-release.apk

# Current build SHA-1 (located in app-release.apk.sha1)
```

---

## 📋 Pre-Deployment Checklist

- [x] App signed with release keystore
- [x] ProGuard/R8 obfuscation enabled
- [x] Debug code removed
- [x] App name and icon configured
- [x] Version number set correctly
- [x] Permissions properly declared
- [x] Firebase configuration included
- [x] Google Maps API key configured
- [x] Release APK tested on physical device

---

## 🛠️ Technical Details

### Build Configuration
- **Android Gradle Plugin:** 8.6.0
- **Kotlin Version:** 1.9.0
- **Compile SDK:** 35
- **Min SDK:** 21 (Android 5.0)
- **Target SDK:** 35 (Android 15)

### Integrated Services
- Firebase Authentication
- Firebase Realtime Database
- Firebase Cloud Messaging
- Firebase Storage
- Firebase Analytics
- Google Maps
- Google Sign-In
- Location Services
- Local Notifications

---

## 🔒 Security Notes

1. **Keystore Backup:**
   - Backup `~/upload-keystore.jks`
   - Store securely (encrypted drive, password manager)
   - Never commit to version control

2. **API Keys:**
   - Google Maps API key is in `AndroidManifest.xml`
   - Crime data API key is in `area_profile.dart`
   - Consider moving to environment variables for better security

3. **Firebase:**
   - `google-services.json` contains Firebase config
   - Ensure Firebase Security Rules are properly configured
   - Monitor Firebase usage in console

---

## 📞 Distribution Options

### Current: Direct Website Download
- ✅ Full control over distribution
- ✅ No store approval needed
- ✅ Instant updates
- ⚠️ Users must enable "Unknown Sources"
- ⚠️ No automatic updates

### Future: Google Play Store
Benefits:
- Wider reach and discoverability
- Automatic updates
- User reviews and ratings
- Google Play Protect scanning
- No "Unknown Sources" requirement

Requirements:
- Google Play Developer account ($25 one-time)
- App signing by Google Play
- Store listing with screenshots
- Privacy policy
- Content rating

---

## 🎯 Next Steps

1. **Test the APK** on multiple devices
2. **Upload to your web server**
3. **Create download landing page**
4. **Test download process** from your website
5. **Prepare user documentation**
6. **Set up analytics** to track downloads
7. **Plan update strategy**

---

## 📝 Build Commands Reference

```bash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Build release APK (single APK for all architectures)
flutter build apk --release

# Build split APKs per architecture (smaller file sizes)
flutter build apk --release --split-per-abi

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Check APK size
flutter build apk --release --analyze-size
```

---

## 🐛 Troubleshooting

### Users can't install APK
- Ensure "Unknown Sources" is enabled
- Check if device has enough storage (55+ MB free)
- Verify APK wasn't corrupted during download

### App crashes on launch
- Check if all permissions are granted
- Ensure device has Google Play Services
- Verify Firebase configuration is correct

### Location features not working
- User must grant location permissions
- Background location permission is critical
- Ensure location services are enabled on device

---

## 📄 Important Files Created/Modified

1. `~/upload-keystore.jks` - Release signing keystore
2. `android/key.properties` - Keystore configuration
3. `android/app/build.gradle` - Build configuration with signing
4. `android/app/proguard-rules.pro` - Code obfuscation rules
5. `.gitignore` - Updated to exclude sensitive files
6. `build/app/outputs/flutter-apk/app-release.apk` - Final release APK

---

**🎉 Your app is ready for distribution! Good luck with your release!**
