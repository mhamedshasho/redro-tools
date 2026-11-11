# Redro PDF — implementation and verification status

This checklist distinguishes features present in source from requirements actually validated. An implemented UI path is not proof of platform runtime correctness.

## Current reader milestone

- [x] Flutter app shell branded Redro PDF.
- [x] Local PDF selection and non-empty file check before parsing.
- [x] Multiple document tabs with switch and close controls.
- [x] PDF viewer selected by platform: Android pinch viewer; Windows standard viewer.
- [x] Page count, previous/next, and direct page number navigation.
- [x] English/Arabic copy and LTR/RTL layout toggle.
- [x] Light/dark appearance toggle.
- [x] No editing or conversion controls presented as working.
- [x] Android/Windows CI workflows run analysis and widget tests and validate artifact contents.
- [ ] Latest workflows have passed for the repaired commit and artifacts have been downloaded/reviewed.
- [ ] Open a real PDF in Android and Windows runtime environments.
- [ ] Confirm Arabic, English, and mixed-direction PDF rendering.
- [ ] Verify large, many-page, damaged, encrypted/password-protected and scanned PDFs.
- [ ] Measure memory use and check for UI freezes on representative large files.
- [ ] Verify source files remain unchanged after viewing.

## Not implemented

- [ ] Selectable text and text search.
- [ ] Persistent highlight/underline/strike-through annotations and edit/remove actions.
- [ ] Text boxes, notes, freehand drawing, and signatures.
- [ ] Save edited PDF, reopen it, and verify embedded changes.
- [ ] Rotate, reorder, extract, delete, merge, or split pages.
- [ ] Genuine PDF-to-DOCX or PDF-to-XLSX conversion.
- [ ] Local OCR for Arabic and English scanned documents.
- [ ] Persist language/theme settings across relaunch.
- [ ] In-app GitHub Release version check, download, and user-approved update handoff.
- [ ] Stable Android release signing key and a release APK.
- [ ] Windows launch test on a separate Windows host.
- [ ] Versioned GitHub Releases and checksums.

## Build artifacts

Android CI currently produces an installable debug APK. The debug key is not a stable release key, so it is not an appropriate foundation for signing future update APKs. Windows CI creates a ZIP of the Release output and checks for the executable, Flutter runtime DLL, and ICU data. A successful packaging check does not by itself prove that the application launches or can open PDFs on a Windows device.

## Privacy/testing boundary

The app source has no PDF upload flow. This has not been validated with a network-monitoring test or an independent audit of transitive dependencies. Local processing does not imply encryption at rest or secure deletion.
