# PDF-to-Office conversion decisions

## Conversion path

The app uses `PdfTextExtractor.extractTextLines` page by page to preserve the extractor's line sequence. Its public API exposes both text and line bounds. The current output path writes each extracted line as editable text rather than claiming to reconstruct the original PDF layout. [1] [2]

For Word, the app creates a minimal Open XML `.docx` package with page headings, editable paragraphs, page breaks, and basic right-to-left markup on lines containing Arabic-script characters. It does not currently insert source images or reproduce fonts, columns, tables, or precise page positioning. The archive library provides ZIP package encoding; no cloud service or document upload is used. [3]

For Excel, the MIT-licensed `excel` package creates an `.xlsx` workbook. Each extracted PDF line becomes an editable row with page and line-number columns. This is useful for searchable/editable text, but it is not table detection: columns, cell boundaries, and data types are not inferred from PDF geometry. [4]

## Important limits

Text extraction only works where the PDF contains a usable text layer. An image-only scanned page can return no lines; the app reports that OCR is needed rather than silently presenting an empty conversion as success. OCR, image extraction, automatic table reconstruction, and original-layout fidelity are future capabilities, not current ones. Syncfusion Flutter PDF is commercial software; confirm Community License eligibility or obtain a commercial license before distribution. [2] [5]

## References

[1]: https://pub.dev/documentation/syncfusion_flutter_pdf/latest/pdf/PdfTextExtractor-class.html "PdfTextExtractor API"
[2]: https://help.syncfusion.com/document-processing/pdf/pdf-library/flutter/working-with-text-extraction "Syncfusion Flutter PDF text extraction guide"
[3]: https://pub.dev/documentation/archive/latest/archive/ZipEncoder-class.html "Dart archive ZIP encoder"
[4]: https://pub.dev/packages/excel "Dart and Flutter XLSX library and MIT license"
[5]: https://www.syncfusion.com/products/communitylicense "Syncfusion Community License eligibility"
