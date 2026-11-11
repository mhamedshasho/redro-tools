# Redro PDF Converter — conversion status

The primary workflow is to select a PDF, choose Word or Excel, and save a new output file. The owner tests the conversion quality; no app or PDF feature tests have been run by the assistant.

## Implemented in source

- [x] Two direct choices: PDF to Word and PDF to Excel.
- [x] Local PDF selection and save dialog for the converted file; the source PDF is not overwritten.
- [x] Extract selectable PDF text page by page using the Syncfusion PDF text extractor.
- [x] DOCX creation with editable text paragraphs, page headings, and basic RTL markup for Arabic lines.
- [x] XLSX creation with one row for each extracted text line and page/line number columns.
- [x] User-facing error when no selectable text is found, including a note that scanned-page OCR is not available.
- [x] Logo, Arabic/English app labels, RTL interface direction toggle, and theme toggle.
- [x] Highlighter/editor workflow removed from the primary app.

## Owner testing required

- [ ] Convert a normal text PDF to DOCX and open it in Microsoft Word or another DOCX reader.
- [ ] Convert the same PDF to XLSX and check that the extracted lines and page numbers are editable.
- [ ] Convert Arabic and mixed Arabic/English PDFs and check text order/shaping.
- [ ] Confirm that scanned/image-only PDFs show the OCR limitation rather than a misleading output.
- [ ] Install and try the Android and Windows builds after they are produced.

## Known limits of this first conversion path

Word paragraphs are editable text, but original layout, fonts, images, and exact page positioning are not reconstructed. Excel currently receives one extracted text line per row; table detection and cell reconstruction are not implemented. Scanned pages require OCR, which is not included. No output-quality or app tests are claimed.

## Licensing and updates

PDF extraction uses the commercial Syncfusion Flutter PDF package; confirm eligibility for a Community License or arrange a commercial license before distribution. The `excel` package is MIT-licensed. DOCX is written as Open XML using Dart's `archive` library.

Android package version is `0.3.0+3`, with application ID `com.redro.redro_pdf`. An in-place update requires a compatible signing certificate and higher version code; the current CI setup uses temporary signing.
