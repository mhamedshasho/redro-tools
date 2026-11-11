# Redro PDF Converter — requested editor scope

This document records the product direction requested by the owner. The current app is still a local PDF reader; the features below must not be described as implemented until they are present in the app and the owner has tested them.

## Required user capabilities

1. **Highlight and annotate:** Provide an in-document highlighter tool with color selection, undo, and the ability to select, move, recolor, or delete saved highlights. Save annotations into the PDF or a companion edit state that the app can reopen and later export back into the PDF.
2. **Edit and save PDF content:** Let the user add, edit, move, and remove text and images, then save an updated PDF as a new file or explicitly overwrite the current one. The original should remain safe unless the user chooses overwrite. Preserve the modified result after closing and reopening it.
3. **Export to Word:** Produce an editable DOCX that carries over text, images, and document structure as well as the PDF permits. Keep Arabic/RTL text readable and ordered correctly. Clearly disclose when OCR or layout reconstruction is uncertain.
4. **Export to Excel:** Detect tables and put their text into editable worksheet cells; include related images when possible. For page content that is not tabular, explain the chosen representation instead of silently claiming that a spreadsheet is a faithful editable copy of every PDF element.
5. **Arabic and other languages:** Support RTL editing, mixed Arabic/Latin text, Unicode input and search, and correct Arabic shaping in saved and exported documents. Use original selectable text where present; scanned pages require language-aware OCR.
6. **Responsive UX:** Provide comfortable touch targets and compact navigation on phones, and efficient toolbars, keyboard actions, page navigation, and document panels on Windows desktops. Respect LTR/RTL direction and keep core tools discoverable.
7. **Install and update:** Keep the Android application ID stable. A newer APK must use the same signing certificate as the installed app and a higher version code to update in place. Use a persistent owner-controlled signing key stored as protected CI secrets; do not use ephemeral CI debug keys for update releases.

## Conversion and editing quality rules

A PDF is a fixed-layout page format; Word and Excel are editable document formats. The goal is to preserve the source's text, pictures, tables, and reading order as closely as practical while making extracted content editable. Exact layout and editability cannot be guaranteed for every PDF, especially scanned pages, complex tables, unusual fonts, and mixed Arabic/English layouts. The app must report when OCR was used or when a conversion may be incomplete. It must not silently flatten a whole document to page pictures and label that fully editable Word/Excel output.

For scans, preserve the original page image and add OCR text as a separate aligned layer when supported. For a Word export, page images may be offered as a separate visual-fidelity mode, not as the only editable mode. For Excel, prioritize table/cell extraction and provide the source page/image as context where a region cannot be represented as cells.

## Suggested delivery phases

- **Foundation:** choose a PDF SDK that supports Android and Windows and can persist annotations/content edits; confirm licensing, saved-file format, Arabic text/font handling, and offline operation before binding the UI to it.
- **PDF editor:** responsive viewer shell, highlighter/annotation toolbar, text and image operations, undo/redo, save-as, reopen saved output.
- **Document conversion:** DOCX export with text, pictures, page structure, and RTL; XLSX export for detected tables plus page context; make OCR a separately visible capability.
- **Release/update path:** owner-controlled stable signing identity, monotonically increasing version codes, compatibility checks against the already-installed certificate, and a documented user-approved install/update flow.

## Owner testing boundary

The owner will test editing, rendering quality, language behavior, and conversion output. The assistant must not run feature tests unless asked again. The assistant may prepare builds and perform installation/update compatibility checks when a connected test device, the installed APK or signing identity, and the newer APK are available. A purely static signing/version check is not the same as a successful on-device update.
