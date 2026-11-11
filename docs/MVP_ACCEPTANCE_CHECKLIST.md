# Redro PDF — implementation and verification status

This checklist distinguishes features present in source from requirements validated by CI or a real device. A UI path is not proof of platform runtime correctness.

## Current reader milestone

- [x] Flutter app shell branded Redro PDF.
- [x] Local PDF selection and non-empty file check before parsing.
- [x] Multiple document tabs with switch and close controls.
- [x] Android pinch viewer; Windows standard viewer.
- [x] Page count, previous/next, and direct page-number navigation.
- [x] Per-page rotation in 90-degree increments with export to a separate PDF copy implemented in source (CI and real-file verification pending).
- [x] English/Arabic copy and LTR/RTL layout toggle.
- [x] Light/dark appearance toggle.
- [x] No editing or conversion controls presented as working.
- [x] Android/Windows CI analysis and widget tests pass on commit `5df7186`: [Android run](https://github.com/mhamedshasho/redro-tools/actions/runs/43080853686), [Windows run](https://github.com/mhamedshasho/redro-tools/actions/runs/43080853344).
- [x] Android CI builds three optimized release-mode APKs split by ABI and enforces a size below 100 MB per APK.
- [x] Windows ZIP contents checked, and executable remained running through a five-second smoke test on the hosted CI runner.
- [ ] Install an APK and open a real PDF on an Android device.
- [ ] Open a real PDF on an independent Windows host.
- [ ] Confirm Arabic, English, and mixed-direction PDF rendering.
- [ ] Verify large, many-page, damaged, encrypted/password-protected, and scanned PDFs.
- [ ] Measure memory use and check for UI freezes on representative large files.
- [ ] Verify source files remain unchanged after viewing.

## Not implemented

- [ ] Selectable text and text search.
- [ ] Persistent highlight/underline/strike-through annotations and edit/remove actions.
- [ ] Text boxes, notes, freehand drawing, and signatures.
- [ ] Save edited PDF, reopen it, and verify embedded changes.
- [ ] Verify page rotation and saved-copy reopening with real PDFs.
- [ ] Reorder, extract, delete, merge, or split pages.
- [ ] Genuine PDF-to-DOCX or PDF-to-XLSX conversion.
- [ ] Local OCR for Arabic and English scanned documents.
- [ ] Persist language/theme settings across relaunch.
- [ ] In-app version check, download, and user-approved update handoff.
- [ ] Stable Android release signing key and versioned GitHub Release.

## Build artifacts

The Android workflow produces one APK per ABI. CI-reported sizes are 14,416,087 bytes for `armeabi-v7a`, 17,062,271 bytes for `arm64-v8a`, and 18,570,121 bytes for `x86_64`. Each passed the 100 MB cap and was uploaded in the [`redro-pdf-android-release-split` artifact](https://github.com/mhamedshasho/redro-tools/actions/runs/43080853686). The APKs are optimized release-mode builds signed with an ephemeral CI debug key—not a stable update-signing identity. Windows CI packages the Release output and verifies runtime files; its startup smoke test does not test PDF selection or rendering.

## Privacy/testing boundary

The app source has no PDF upload flow. This has not been validated with network monitoring or an independent audit of transitive dependencies. Local processing does not imply encryption at rest or secure deletion.
