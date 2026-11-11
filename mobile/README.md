# Redro PDF Converter — Flutter app

The Android and Windows source is at commit `82deb04` for the latest build artifacts. Source features include local PDF tabs, page navigation, selectable-text highlighting with four colors, a Save Edited Copy path for annotations, page rotation, the supplied logo, English/Arabic interface labels, and light/dark appearance.

The owner tests PDF behavior. The current Android and Windows builds succeeded, while static analysis, automated tests, and the Windows executable launch check were skipped. The highlighter/save workflow still needs owner testing with real PDFs.

## Latest build downloads

The [Android build run](https://github.com/mhamedshasho/redro-tools/actions/runs/43092534621) contains `redro-pdf-android-release-split`: `app-arm64-v8a-release.apk` (21,944,651 bytes, most current phones), `app-armeabi-v7a-release.apk` (19,904,675 bytes, 32-bit ARM), and `app-x86_64-release.apk` (23,583,573 bytes).

The [Windows build run](https://github.com/mhamedshasho/redro-tools/actions/runs/43092540575) contains `redro-pdf-windows-portable.zip` (16,903,428 bytes). Extract the complete ZIP; keep `redro_pdf.exe`, the DLLs, and `data/` together.

These are Actions artifacts, not a published GitHub Release. They are retained for 30 days. The Android APKs use a temporary CI debug key, so they may not update an app signed with another key. The app identifier is `com.redro.redro_pdf`; the source package version is `0.2.0+2`.

## Not implemented yet

The app does not edit existing PDF text or replace/delete embedded image objects. DOCX/XLSX conversion and Arabic or multilingual OCR are also outstanding. The Syncfusion PDF Viewer is a commercial package; confirm Community License eligibility or arrange a valid license before distributing.

## Build locally

With Flutter stable and the target toolchain installed:

```sh
cd mobile
flutter pub get
flutter build apk --release --split-per-abi
flutter build windows --release
```
