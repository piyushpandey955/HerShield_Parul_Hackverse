# HerShield - Quick Deployment Reference

## 🚀 Your APK is Ready!

**Location:** `build/app/outputs/flutter-apk/app-release.apk`
**Size:** 55.1 MB

---

## 📤 Deploy in 3 Steps

### 1. Upload APK to Your Server
```bash
# Copy APK to your web server
scp build/app/outputs/flutter-apk/app-release.apk user@server.com:/var/www/downloads/
```

### 2. Create Download Link
```html
<a href="/downloads/app-release.apk" download="HerShield.apk">
    Download HerShield v1.0.0
</a>
```

### 3. Share the Link
Users download → Enable Unknown Sources → Install

---

## ⚠️ CRITICAL: Backup These Files

```
~/upload-keystore.jks          (Signing key - NEVER lose this!)
android/key.properties          (Keystore config)
```

**Without the keystore, you cannot release updates!**

---

## 🔄 Release Update Workflow

1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2
   ```

2. Build new APK:
   ```bash
   flutter clean
   flutter build apk --release
   ```

3. Upload to server with new name:
   ```
   HerShield-v1.0.1.apk
   ```

---

## 📋 What Was Done

✅ Created release keystore for signing
✅ Configured ProGuard obfuscation
✅ Removed debug code
✅ Set app name to "HerShield"
✅ Enabled code shrinking
✅ Built production APK
✅ Generated deployment documentation

---

## 🔐 Security Info

**Keystore Password:** hershield2025
**Key Alias:** upload
**Location:** ~/upload-keystore.jks

Store these securely! You'll need them for every future update.

---

## 📱 User Requirements

- Android 5.0+ (API 21+)
- 55+ MB storage
- Google Play Services
- Enable "Install from Unknown Sources"

---

## 🆘 Need to Rebuild?

```bash
cd "/Users/piyush/Documents/project jarves/flutter/HerShield_Parul_Hackverse/hershield"
flutter clean
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📖 Full Documentation

See `RELEASE_DEPLOYMENT_GUIDE.md` for complete details.
