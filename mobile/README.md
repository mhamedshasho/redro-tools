# Redro PDF Converter

The app has a simple local conversion flow: choose **PDF to Word** or **PDF to Excel**, select a PDF, then choose where to save the result. The original PDF is not changed and no document is uploaded.

Word output (`.docx`) contains editable extracted text, organized by page. Excel output (`.xlsx`) places each extracted PDF text line in its own row and records its page/line number. This version does not reconstruct the original layout, embedded images, or spreadsheet table cells. Scanned PDFs without a text layer need OCR, which is not included yet.

Feature behavior remains for the owner to test; I have not run tests. The current app version is `0.3.0+3`, targeting Android and Windows. The Android application ID remains `com.redro.redro_pdf`; an in-place update also needs a signing key compatible with the installed app.

Build from this directory with Flutter stable and the platform toolchain installed:

```sh
flutter pub get
flutter build apk --release --split-per-abi
flutter build windows --release
```

PDF text extraction uses the commercial Syncfusion Flutter PDF library; verify licensing before distributing. XLSX generation uses the MIT-licensed `excel` package. DOCX is generated as Open XML using the Dart `archive` package.
