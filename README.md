# Redro PDF Converter

Redro PDF is a Flutter app for Android and Windows. The current source now includes a PDF highlighter/save-copy path; it is not yet the complete text-and-image editor or Office converter requested by the owner.

## In the current source

- Opens local PDFs and keeps multiple documents in tabs.
- Uses a shared PDF viewer with page navigation, text selection, and a highlighter mode with several colors.
- Saves the viewer's PDF annotation bytes to a separate edited-copy file; the source file is not overwritten by default.
- Includes page rotation in the current source.
- Shows the supplied Redro PDF Converter logo in the app header and home screen.
- Provides English/Arabic interface labels, LTR/RTL UI direction, and light/dark themes.
- Opens files locally; there is no document-upload flow.

The owner will test feature behavior. No PDF feature tests were run for these changes. The latest built APKs are older than the highlighter/viewer changes and should not be treated as a current build.

## Still to implement

- Editing existing PDF text in place.
- Adding, moving, replacing, and deleting images inside PDFs.
- Word export with editable text/images and Arabic/RTL reconstruction.
- Excel export that detects tables and creates editable cells.
- OCR for scanned pages, especially Arabic and mixed Arabic/English.
- Stable APK signing and a reliable in-place update channel.

The Syncfusion PDF Viewer is a commercial package with a Community License available only to eligible organizations. Confirm the project's eligibility and license terms before distributing builds that use it. Exact PDF-to-Word/Excel fidelity cannot be guaranteed for all PDFs; scans need OCR, and PDF page appearance does not always contain recoverable paragraph/table structure. See [`docs/EDITOR_REQUIREMENTS.md`](docs/EDITOR_REQUIREMENTS.md) and [`docs/EDITOR_TECHNICAL_DECISIONS.md`](docs/EDITOR_TECHNICAL_DECISIONS.md).

## Build

Install Flutter stable and the Android SDK or Windows desktop toolchain, then run from `mobile/`:

```sh
flutter pub get
flutter build apk --release --split-per-abi
flutter build windows --release
```

These commands build the source; the owner is responsible for feature testing.

## Android install and update requirements

The Android application ID is `com.redro.redro_pdf`. For Android to update an installed app in place, keep that ID, sign the new APK with a compatible version of the same signing key, and increase the `versionCode`. The previously published CI APKs used an ephemeral debug key and are not a reliable update base. A trusted persistent signing key and the installed APK's signing identity are required before validating an update.

Previous Android and Windows artifacts remain available from their earlier CI runs, but they predate the current highlighter source. Windows distribution is currently a portable ZIP; there is no installer/updater yet.
