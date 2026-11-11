# Redro PDF Converter — implementation status

This checklist separates source code from owner verification. The owner tests PDF behavior; the assistant is not running feature tests.

## Present in current source

- [x] Redro logo assets and branded home/header UI.
- [x] Local PDF selection and multiple document tabs.
- [x] Shared Android/Windows viewer dependency with page navigation and text selection.
- [x] Highlighter mode and a small highlight-color palette in the editor toolbar.
- [x] Save Edited Copy writes the PDF viewer's serialized document bytes to a separate file; highlight annotations are intended to persist in that copy.
- [x] Page-rotation data and save-copy path are present in source.
- [x] English/Arabic interface labels and LTR/RTL UI direction toggle.
- [x] Light/dark appearance control.

## Owner testing still required

- [ ] Build and open a local PDF on Android and Windows.
- [ ] Select text with the highlighter, create highlights, change color, and save a copy.
- [ ] Reopen the saved PDF in Redro and in another PDF viewer; confirm highlights persist and can be selected/deleted.
- [ ] Check Arabic-only, English-only, and mixed Arabic/English PDFs.
- [ ] Test page rotation and saved-copy behavior.
- [ ] Test unsaved edits, large files, encrypted files, and damaged PDFs.

No tests were run by the assistant for these changes, at the owner's request. The previous CI APK/Windows artifacts predate the new viewer and highlight source.

## Still not implemented

- [ ] Direct editing of existing PDF text objects.
- [ ] Insert, move, replace, and remove image objects in a PDF.
- [ ] Editable DOCX conversion with images, text, and Arabic/RTL.
- [ ] XLSX table detection and editable cells, with image/page context where appropriate.
- [ ] Arabic and multilingual OCR for scanned pages.
- [ ] A stable Android signing key and update APK compatible with an existing installation.
- [ ] A Windows installer/updater.

## Platform and licensing decisions

The current annotation path uses Syncfusion's Flutter PDF Viewer, whose package documents Android and Windows support, text markup, and saving serialized document bytes. It is a commercial package; confirm eligibility for Syncfusion's Community License before distributing. The existing `syncfusion_flutter_pdf` page-rotation engine is a separate dependency and its Windows support has not been established here. See [`EDITOR_TECHNICAL_DECISIONS.md`](EDITOR_TECHNICAL_DECISIONS.md) for sources and remaining engine trade-offs.

The APK's Android application ID is `com.redro.redro_pdf`. An in-place APK update requires the same application ID, a compatible signing certificate, and a higher version code. Earlier CI artifacts use an ephemeral debug key, so they are not a valid long-term update baseline. A test update also requires the actual installed APK or trusted signer fingerprint and an Android device/emulator.
