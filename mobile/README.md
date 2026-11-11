# Redro PDF Converter — Flutter app

The Flutter source targets Android and Windows. It uses a shared PDF viewer and currently includes local PDF tabs, page navigation, selectable-text highlighting, highlight colors, and Save Edited Copy. Page rotation is also present in source. The owner has not yet tested these editing changes; no feature tests were run by the assistant.

The app includes the Redro PDF Converter logo and an English/Arabic interface direction toggle. This does not yet establish Arabic OCR or perfect mixed-script rendering in exported documents.

## Not implemented yet

The current code does not edit existing page text or replace/delete embedded image objects. DOCX/XLSX conversion and scanned-PDF OCR are also still outstanding. The requested Office exports must preserve as much editable text, images, and table data as the source permits; they must not be presented as complete if the output is only page images.

The app uses Syncfusion's commercial Flutter PDF Viewer. The owner must confirm eligibility for the Syncfusion Community License or arrange another valid license before distribution.

## Build locally

With Flutter stable and the target platform toolchain installed:

```sh
cd mobile
flutter pub get
flutter build apk --release --split-per-abi
flutter build windows --release
```

The owner tests app behavior. The assistant is not running PDF feature tests.

## Android updates

The Android application ID must remain `com.redro.redro_pdf`. Updating an existing installation requires a newer version code and a signing certificate compatible with the APK already installed. Earlier CI artifacts were signed with an ephemeral debug key; they are not a stable update channel. The Windows package is a portable ZIP, with no setup/updater yet.
