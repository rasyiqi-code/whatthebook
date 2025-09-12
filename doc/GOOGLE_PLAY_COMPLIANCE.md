# Google Play Store Compliance - WhatTheBook

## Status Compliance

### ✅ Sudah Compliant
- **Permission:** Hanya menggunakan `INTERNET` permission (tidak ada permission sensitif)
- **Firebase Setup:** File `google-services.json` sudah ada di lokasi yang benar
- **Struktur Project:** Mengikuti standar Flutter
- **Kebijakan Privasi:** File `PRIVACY_POLICY.md` sudah dibuat
- **Syarat & Ketentuan:** File `TERMS_OF_SERVICE.md` sudah dibuat
- **UI Privacy:** Halaman privasi di aplikasi sudah ditambahkan dengan link ke kebijakan

### ⚠️ Perlu Verifikasi
- **Target SDK:** Menggunakan `flutter.targetSdkVersion` (perlu cek nilai sebenarnya)
- **Min SDK:** 23 (sudah cukup untuk Play Store)

### 📋 Checklist Sebelum Upload

#### 1. Konfigurasi SDK
- [ ] Pastikan targetSdk minimal 31 (Android 12)
- [ ] Pastikan compileSdk minimal 31
- [ ] Test di berbagai versi Android (API 23+)

#### 2. Kebijakan Privasi
- [ ] Upload file `PRIVACY_POLICY.md` ke website
- [ ] Update link di aplikasi ke URL yang benar
- [ ] Pastikan link bisa diakses dari aplikasi

#### 3. Syarat & Ketentuan
- [ ] Upload file `TERMS_OF_SERVICE.md` ke website
- [ ] Update link di aplikasi ke URL yang benar
- [ ] Pastikan link bisa diakses dari aplikasi

#### 4. Testing
- [ ] Test aplikasi di emulator Android 12+ (API 31+)
- [ ] Test aplikasi di emulator Android 6+ (API 23)
- [ ] Pastikan tidak ada crash atau error
- [ ] Test semua fitur utama

#### 5. Play Console Setup
- [ ] Buat akun Google Play Console
- [ ] Setup aplikasi di Play Console
- [ ] Upload APK/AAB untuk testing
- [ ] Isi semua informasi yang diperlukan

## Langkah Selanjutnya

### 1. Verifikasi SDK Version
```bash
flutter doctor
flutter --version
```

### 2. Build dan Test
```bash
flutter build apk --release
flutter build appbundle --release
```

### 3. Update Links
Ganti URL placeholder di aplikasi:
- `https://whatthebook.com/privacy` → URL kebijakan privasi yang sebenarnya
- `https://whatthebook.com/terms` → URL syarat & ketentuan yang sebenarnya

### 4. Implement URL Launcher
Tambahkan package `url_launcher` untuk membuka link dari aplikasi:
```yaml
dependencies:
  url_launcher: ^6.1.14
```

### 5. Testing Checklist
- [ ] Aplikasi tidak crash saat startup
- [ ] Semua fitur utama berfungsi
- [ ] Halaman privasi bisa diakses
- [ ] Link kebijakan privasi berfungsi
- [ ] Link syarat & ketentuan berfungsi
- [ ] Aplikasi berjalan di Android 6+ (API 23+)

## Catatan Penting

1. **Target SDK 31+:** Google Play Store mengharuskan target SDK minimal 31 untuk aplikasi baru yang diupload setelah Agustus 2023.

2. **Kebijakan Privasi:** Wajib ada dan bisa diakses dari aplikasi untuk aplikasi yang mengumpulkan data pengguna.

3. **Permission:** Aplikasi ini hanya menggunakan permission `INTERNET` yang tidak sensitif, sehingga tidak memerlukan justifikasi khusus.

4. **Firebase:** Pastikan SHA-1/SHA-256 sudah didaftarkan di Firebase Console untuk fitur autentikasi.

5. **Testing:** Sangat penting untuk test di berbagai device dan versi Android sebelum upload.

## Troubleshooting

### Jika targetSdk < 31:
1. Update Flutter SDK ke versi terbaru
2. Rebuild project
3. Cek `flutter doctor` untuk memastikan

### Jika ada permission error:
- Aplikasi ini hanya menggunakan `INTERNET` permission
- Tidak ada permission sensitif yang perlu justifikasi

### Jika ada crash saat testing:
1. Cek log error
2. Test di device yang berbeda
3. Pastikan semua dependency ter-update

## Contact

Untuk pertanyaan tentang compliance, hubungi:
- **Email:** compliance@whatthebook.com
- **Developer:** [Nama developer]
- **Legal:** [Nama legal team]

---

**Last Updated:** [Tanggal hari ini]
**Version:** 1.0.0 