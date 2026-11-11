# Redro PDF — Flutter application

This repository currently contains the local PDF reader milestone for Android and Windows.

## Implemented

- Local PDF selection using the platform file picker.
- Multiple open document tabs.
- PDF rendering, page count, previous/next navigation, and direct page-number navigation.
- Rotate the current page in 90-degree increments and save a separate edited PDF copy using the Syncfusion PDF engine. The original document is never overwritten.
- Android pinch zoom; the standard PDF view is used on Windows because the `pdfx` pinch viewer is not supported there.
- English/Arabic interface copy with RTL/LTR direction switching.
- Light/dark appearance switching.
- No account, document upload, or cloud-storage flow.

Other editing features are not implemented yet: text selection, persistent highlights/underline/strike-through, notes, drawing, signatures, page reorder/delete/extract, merging/splitting, DOCX/XLSX conversion, OCR, update checking/downloading, and stable release signing. Page rotation and saving a separate rotated copy are the first editing operations added; they still require successful CI and real-file verification. The widget tests do not open real PDFs. Do not advertise these capabilities as available.

## Android APKs

Android CI creates optimized release-mode APKs split by ABI. The uploaded artifact `redro-pdf-android-release-split` contains `app-arm64-v8a-release.apk` (about 17.1 MB), `app-armeabi-v7a-release.apk` (about 14.4 MB), and `app-x86_64-release.apk` (about 18.6 MB). Select the file that matches the target device; most current phones use arm64. The APKs use an ephemeral CI debug signing key, not a stable release/update key. See the latest [Android Actions run](https://github.com/mhamedshasho/redro-tools/actions/runs/43080853686).

## Local development

Install Flutter stable and the target platform's toolchain, then run:

```sh
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

Windows CI generates the desktop scaffold, builds the Release directory, packages runtime files, and performs a five-second executable startup smoke test. The latest [Windows Actions run](https://github.com/mhamedshasho/redro-tools/actions/runs/43080853344) passed. Remaining device-test limitations and unfinished product requirements are recorded in the root README and `docs/MVP_ACCEPTANCE_CHECKLIST.md`.

## Identity and privacy

The Android package identifier is fixed in CI as `com.redro.redro_pdf`; the launcher label is `Redro PDF`. Do not change the identifier for a compatible upgrade.

PDF content is opened from a local file path. The app does not upload document contents. This does not provide encryption at rest or secure deletion guarantees.
