# Redro PDF Converter

Redro PDF is now focused on one task: choose a local PDF, choose **Word** or **Excel**, and save the converted file. The app does not modify the source PDF, and the PDF highlighter/reader workflow has been removed from the main screen.

## Conversion behavior

**PDF to Word** extracts selectable text page by page and writes it into an editable `.docx`, with page headings and basic right-to-left paragraph direction for Arabic text. **PDF to Excel** writes each extracted line into an editable row with page and line numbers in one worksheet. Both conversions run locally on the device.

This first conversion path does not preserve the original page design or embedded images. Excel currently exports text lines; it does not detect table boundaries or reconstruct cells. Scanned-image pages without selectable text are reported instead of silently producing empty output. OCR is not included, and no feature tests have been run at the owner's request.

## Build

The app targets Android and Windows. The current source package version is `0.3.0+3`. From `mobile/`, run `flutter pub get`, then `flutter build apk --release --split-per-abi` for Android or `flutter build windows --release` for Windows.

The Android application ID remains `com.redro.redro_pdf`. Updating an existing installation requires the same application ID, a compatible signing certificate, and a higher version code. Current CI builds use temporary signing and may not update an app signed with a different key.

## Dependencies and license notes

PDF text extraction uses Syncfusion Flutter PDF, which is a commercial package; confirm Community License eligibility or obtain a commercial license before distribution. XLSX generation uses the MIT-licensed `excel` package. DOCX generation writes the Open XML package using Dart's `archive` ZIP library.
