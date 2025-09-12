# SHA Keystore Information - WhatTheBook

**Last Updated:** 10 Juli 2025

## Overview
Dokumentasi ini berisi informasi SHA fingerprint untuk debug dan release keystore yang digunakan dalam aplikasi WhatTheBook.

## Debug Keystore (Development)

### Location
```
%USERPROFILE%\.android\debug.keystore
```

### Command untuk mendapatkan SHA
```bash
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### SHA Fingerprints
- **SHA-1**: `53:95:72:BE:AD:BF:A2:BD:50:1C:B0:7B:64:4E:F4:A0:4B:8E:BF:19`
- **SHA-256**: `17:A2:80:D4:AC:D0:43:F7:8B:73:9C:FE:69:98:8D:FE:FB:49:D0:A6:E2:5C:D6:13:27:3F:C9:73:C3:CA:C4:A3`

### Digunakan untuk
- Development dan testing
- Firebase Authentication (development)
- Local builds

## Release Keystore (Production)

### Location
```
D:\whatthebook\android\app\keystore\my-release-key.jks
```

### Configuration
File: `android/app/key.properties`
```
storePassword=Rasyoke45@
keyPassword=Rasyoke45@
keyAlias=whatthebook
storeFile=keystore/my-release-key.jks
```

### Command untuk mendapatkan SHA
```bash
keytool -list -v -keystore "android/app/keystore/my-release-key.jks" -alias whatthebook -storepass Rasyoke45@ -keypass Rasyoke45@
```

### SHA Fingerprints
- **SHA-1**: `AB:18:32:59:2A:FD:1A:D3:9E:E7:99:0A:F5:D4:37:43:37:5D:A8:CC`
- **SHA-256**: `04:C4:04:39:55:B3:F6:8B:02:BF:82:53:6A:B6:2B:A7:39:5D:1B:D3:4A:7C:4D:2B:28:AE:4F:1B:50:24:67:EC`

### Certificate Details
- **Owner**: CN=Rasyiqi, OU=Crediblemark, O=PT. Retas Lintas Batas, L=Sumenep, ST=East Java, C=id
- **Issuer**: CN=Rasyiqi, OU=Crediblemark, O=PT. Retas Lintas Batas, L=Sumenep, ST=East Java, C=id
- **Valid From**: Thu Jul 10 19:07:35 WIB 2025
- **Valid Until**: Mon Nov 25 19:07:35 WIB 2052
- **Serial Number**: bf82cc8abaebb302
- **Signature Algorithm**: SHA384withRSA
- **Key Algorithm**: 2048-bit RSA key

### Digunakan untuk
- Production builds
- Google Play Store uploads
- Firebase Authentication (production)
- Release APK signing

## Firebase Setup

### Development Environment
Tambahkan SHA-1 debug ke Firebase Console:
```
53:95:72:BE:AD:BF:A2:BD:50:1C:B0:7B:64:4E:F4:A0:4B:8E:BF:19
```

### Production Environment
Tambahkan SHA-1 release ke Firebase Console:
```
AB:18:32:59:2A:FD:1A:D3:9E:E7:99:0A:F5:D4:37:43:37:5D:A8:CC
```

## Google Play Store

### Required SHA
Untuk upload ke Google Play Store, gunakan **hanya** SHA dari release keystore:
- **SHA-1**: `AB:18:32:59:2A:FD:1A:D3:9E:E7:99:0A:F5:D4:37:43:37:5D:A8:CC`

## Security Notes

### Keystore Protection
- **Debug keystore**: Default password (android)
- **Release keystore**: Custom password (Rasyoke45@)
- **Backup**: Pastikan release keystore di-backup dengan aman
- **Version Control**: Jangan commit keystore ke repository

### Best Practices
1. Simpan backup release keystore di lokasi aman
2. Jangan share password keystore
3. Gunakan environment variables untuk password di CI/CD
4. Rotate keystore secara berkala untuk security

## Troubleshooting

### Common Issues

#### "Keystore password was incorrect"
- Pastikan menggunakan password yang benar
- Debug: `android`
- Release: `Rasyoke45@`

#### "Keystore file does not exist"
- Debug: Pastikan Android SDK terinstall
- Release: Pastikan file ada di `android/app/keystore/my-release-key.jks`

#### Firebase Authentication not working
- Pastikan SHA-1 sudah ditambahkan ke Firebase Console
- Gunakan SHA debug untuk development
- Gunakan SHA release untuk production

## Commands Reference

### Generate new debug keystore
```bash
keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000
```

### Generate new release keystore
```bash
keytool -genkey -v -keystore android/app/keystore/my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias whatthebook
```

### Verify keystore integrity
```bash
keytool -list -v -keystore [keystore_path] -alias [alias_name]
```

---

**Note**: Informasi ini bersifat rahasia dan hanya untuk internal development team. 