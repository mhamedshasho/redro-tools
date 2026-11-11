# Redro PDF — MVP acceptance checklist

## Current implementation snapshot

- [x] Flutter application entry point and adaptive Material interface foundation.
- [x] Local PDF file picker integration.
- [x] PDF viewing surface with pinch zoom.
- [x] English and Arabic interface labels with RTL direction switching.
- [x] Light/dark theme switching.
- [x] Android and Windows CI build definitions.
- [ ] CI build has completed successfully and generated downloadable artifacts.
- [ ] Device-level PDF compatibility tests completed.
- [ ] Persistent PDF annotations implemented and verified.

The checked items above indicate code has been added to the branch; they are not a claim that a release build or device test has passed.

## First test build

- [ ] Launches on supported Android devices and Windows 10/11.
- [ ] Opens a PDF selected from local storage.
- [ ] Renders Arabic, English and mixed-direction pages correctly.
- [ ] Page navigation, zoom, fit-to-width and rotation work.
- [ ] Text selection works on selectable-text PDFs.
- [ ] Highlight tool supports at least yellow, green, blue and pink.
- [ ] Highlights remain after saving, closing and reopening the exported PDF.
- [ ] Original input remains unchanged unless overwrite is explicitly selected.
- [ ] Large documents do not freeze the interface; rendering is incremental.
- [ ] Clear error messages for password-protected, damaged and unsupported PDFs.
- [ ] No network request is needed to open, view, annotate or save a local PDF.

## Conversion milestone

- [ ] PDF to DOCX creates a real editable DOCX package.
- [ ] PDF to XLSX creates a real editable XLSX workbook.
- [ ] Tables are mapped into rows and columns where structure can be detected.
- [ ] Reading order and RTL paragraphs are preserved where possible.
- [ ] Scanned PDFs are identified and routed through OCR rather than silently producing empty files.
- [ ] Conversion quality limitations are shown to the user.
- [ ] Output files are reopened/validated before success is reported.

## Release and update milestone

- [ ] GitHub Actions builds signed Android APK and Windows portable ZIP.
- [ ] Android package ID and signing key are stable across releases.
- [ ] In-app update check reads the latest GitHub Release.
- [ ] Download opens Chrome when available, otherwise the system browser.
- [ ] APK update is user-approved by Android and preserves app data.
- [ ] Windows update replaces application binaries safely and preserves user data.
- [ ] SHA-256 checksums are published for release assets.

## Non-functional requirements

- Simple interface with no dense toolbars on phones.
- Adaptive phone and desktop layouts.
- Arabic and English UI with proper RTL/LTR switching.
- Dark and light themes.
- No placeholder controls.
- No silent data loss.
- Measure actual APK and Windows ZIP sizes; target approximately 99 MB without removing essential functionality.
