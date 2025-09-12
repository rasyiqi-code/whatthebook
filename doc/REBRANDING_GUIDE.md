# Rebranding Guide for WhatTheBook / Alhuda Library

This document outlines the steps and key locations in the codebase to update when performing a rebranding of the app, such as changing the app name or visible branding.

## 1. Update App Name Constant

- File: `lib/core/constants/app_constants.dart`
- Change the `appName` constant to the new app name.
- This constant is used in the main app title and other places.

## 2. Update MaterialApp Title

- File: `lib/main.dart`
- Update the `title` property of `MaterialApp` to use the new app name constant or hardcoded string.

## 3. Update Visible Text in UI

- Files to check and update visible app name text:
  - `lib/features/auth/presentation/pages/login_page.dart` (login screen title)
  - `lib/features/auth/presentation/pages/guest_home_page.dart` (guest home app bar title)
  - `lib/features/books/presentation/pages/books_page.dart` (welcome text)
  - `lib/features/auth/presentation/pages/settings/help_page.dart` (about page text)

## 4. Update PDF Export Text

- File: `lib/core/services/pdf_export_service.dart`
- Update any text mentioning the old app name in exported PDFs.

## 5. Update Email and Support References

- Files where support email or references to old app name appear (e.g., help page).
- Update to new branding as needed.

## 6. Update Assets (Optional)

- Update app icons, logos, splash screens if they contain old branding.
- Locations:
  - `android/app/src/main/res/`
  - `ios/Runner/Assets.xcassets/`

## 7. Test Thoroughly

- Verify all UI screens show the new app name correctly.
- Test navigation and functionality to ensure no regressions.
- Check exported PDFs and emails for correct branding.

---

## Notes

- Avoid changing package names or function names unless necessary.
- Focus on visible text and assets for rebranding.
- Keep a backup before making bulk changes.

---

This guide should be updated as the app evolves or if new branding-related code is added.
