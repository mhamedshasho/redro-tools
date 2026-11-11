# Redro PDF Editor & Converter

A lightweight, offline-first PDF application for Android and Windows.

## Product direction

- **Android:** signed APK with in-app release checking and user-approved updates.
- **Windows:** portable release package (EXE plus its required runtime files), no installer required.
- **Offline-first:** PDF viewing, editing and local file operations work without an internet connection. Internet is only needed to check/download updates.
- **Languages:** Arabic and English, with correct RTL/LTR layout and mixed-script text handling.
- **Design:** simple, adaptive interface for phones and desktop screens; Redro red, charcoal and black identity with light/dark themes.

## Core features

1. Open and view local PDF files.
2. Add, edit, remove and save persistent highlights, with multiple colors.
3. Add annotations, text notes, drawings and signatures.
4. Organize pages: rotate, reorder, extract, delete, split and merge.
5. Convert PDF to editable DOCX and XLSX where the source structure permits reliable reconstruction.
6. OCR for scanned Arabic and English documents, subject to on-device engine support.
7. Export and verify the resulting files without uploading documents.

## Quality requirements

- Never report a conversion or save as successful until the output file has been created and checked.
- Preserve the original file unless the user explicitly chooses to overwrite it.
- Test Arabic RTL, English LTR, mixed Arabic/English, tables, scanned pages, large files and malformed PDFs.
- Keep user data and settings across application updates.
- Do not ship placeholder buttons or claim unsupported editing capabilities.
- Target package size: approximately 99 MB, measured from actual release artifacts. This is a target, not a promise that overrides correctness.

## Builds and releases

GitHub Actions will build Android APK and Windows portable artifacts. Windows portable delivery is a ZIP containing the EXE and required Flutter runtime files; a lone EXE is not sufficient for a normal Flutter desktop build. GitHub Releases will host versioned downloads and release notes.

Android updates must use the same application ID and signing key as the installed build. Android will always require the user's approval to install an APK update. The app can request Chrome specifically when Chrome is installed, with a safe system-browser fallback.

## Development status

Initial planning branch: `redro-pdf-mvp`

The first milestone is a stable PDF test build: open local PDFs, navigate pages, highlight selected text, save annotations, reopen the exported PDF, and verify Arabic/English rendering. Conversion and OCR will be added only after the PDF editing foundation is validated.

## Privacy

Documents are processed locally. No account or cloud upload is required for core functionality.

## License

To be finalized after the document-processing dependencies and their licenses are reviewed.
