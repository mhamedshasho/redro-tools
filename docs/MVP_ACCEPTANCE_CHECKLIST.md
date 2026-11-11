# Redro PDF Converter — implementation status

This checklist separates source/build availability from user-facing behavior. The owner tests PDF behavior; the assistant did not run app tests.

## Present in source and packaged in the current build

- [x] Redro logo assets and branded UI.
- [x] Local PDF selection, multiple document tabs, and page navigation.
- [x] Shared Android/Windows PDF viewer dependency.
- [x] Highlighter mode and four highlight colors.
- [x] Save Edited Copy serializes viewer annotation bytes to a separate PDF file.
- [x] Page rotation code and save-copy path.
- [x] English/Arabic interface labels, LTR/RTL UI toggle, and light/dark appearance.
- [x] Android release APKs built successfully from `82deb04`: [Android Actions run](https://github.com/mhamedshasho/redro-tools/actions/runs/43092534621).
- [x] Windows portable ZIP built and package contents verified from `82deb04`: [Windows Actions run](https://github.com/mhamedshasho/redro-tools/actions/runs/43092540575).

The manual runs skipped static analysis, automated tests, and the Windows executable launch check, as requested. Successful compilation/package creation does not prove that the annotation/save behavior works on real PDFs.

## Owner testing still required

- [ ] Install/open the current APK on Android and open a real PDF.
- [ ] Open a real PDF in the Windows executable.
- [ ] Highlight text, change color, save a copy, reopen it, and verify the annotation persists.
- [ ] Check deletion/editing of highlights, Arabic-only/English-only/mixed-direction PDFs, page rotation, and large/encrypted/damaged files.
- [ ] Test whether the new APK updates the currently installed app. It requires a compatible signer; the CI APKs use a temporary debug key.

## Still not implemented

- [ ] Direct editing of existing PDF text objects.
- [ ] Insert, move, replace, and remove embedded image objects.
- [ ] Editable DOCX conversion with text/images and Arabic/RTL.
- [ ] XLSX table detection and editable cells.
- [ ] Arabic/multilingual OCR for scans.
- [ ] Stable Android release signing and a reliable in-place update channel.
- [ ] Windows installer/updater.

## Artifact details

Current APK sizes: `armeabi-v7a` 19,904,675 bytes; `arm64-v8a` 21,944,651 bytes; `x86_64` 23,583,573 bytes. The Windows portable ZIP is 16,903,428 bytes. The runs are [Android](https://github.com/mhamedshasho/redro-tools/actions/runs/43092534621) and [Windows](https://github.com/mhamedshasho/redro-tools/actions/runs/43092540575). These are 30-day Actions artifacts, not a published GitHub Release.

The Android application ID is `com.redro.redro_pdf`, and the source package version is `0.2.0+2`. An in-place update requires the same application ID, compatible signing certificate, and a higher version code.
