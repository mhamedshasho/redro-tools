# Redro PDF Editor & Converter

Flutter application foundation for Android and Windows.

## Current milestone

- Native Flutter application shell
- Local PDF selection
- PDF rendering with pinch zoom
- Light and dark themes
- No account, upload, or cloud document storage

This is the reader foundation only. Editing annotations, page operations, OCR, DOCX/XLSX conversion, update delivery, and signed release packaging are not implemented yet and must not be presented as available features.

## Build locally

Install Flutter stable and the Android or Windows toolchain, then:

```sh
cd mobile
flutter pub get
flutter run
```

## Privacy

PDF files are opened from local device storage. The app does not upload document contents.

## Release requirements

Android releases must keep a stable application ID and signing key. Windows portable releases must include the executable and all required runtime files in a ZIP; an EXE alone is not assumed to be self-contained.
