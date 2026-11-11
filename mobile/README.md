# Redro PDF — Flutter application

This repository currently contains the local PDF reader milestone for Android and Windows.

## Implemented

- Local PDF selection using the platform file picker.
- Multiple open document tabs.
- PDF rendering, page count, previous/next navigation, and direct page-number navigation.
- Android pinch zoom; the standard PDF view is used on Windows because the `pdfx` pinch viewer is not supported there.
- English/Arabic interface copy with RTL/LTR direction switching.
- Light/dark appearance switching.
- No account, document upload, or cloud storage flow.

## Not implemented

There is no PDF editing/writing, highlights, text selection, notes, drawing, signatures, page operations, merging/splitting, DOCX/XLSX conversion, OCR, update checking/downloading, or stable release signing. The current widget tests do not open real PDF files. Do not advertise these capabilities as available.

## Local development

Install Flutter stable and the target platform's toolchain, then run:

```sh
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

The Android CI job generates platform scaffolding and builds a debug APK against compile SDK 36. The Windows CI job generates Windows scaffolding and builds a portable Release ZIP containing runtime files. Build results and remaining device-test limitations are recorded in the root README and `docs/MVP_ACCEPTANCE_CHECKLIST.md`.

## Identity and privacy

The Android package identifier is fixed in CI as `com.redro.redro_pdf`; the launcher label is `Redro PDF`. Do not change the identifier for a compatible upgrade. The CI debug key is ephemeral and must not be used as a release/update signing key.

PDF content is opened from a local file path. The app does not upload document contents. This does not provide encryption at rest or secure deletion guarantees.
