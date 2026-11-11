# Redro editor implementation decisions

This note records the platform and document-engine findings used to guide the requested editor. It is not a claim that the listed features have already been implemented.

## First cross-platform editing step: annotations

The Syncfusion Flutter PDF Viewer documents Android and Windows support, text selection, text-markup annotations, and saving the modified document as bytes through `PdfViewerController.saveDocument()`. Its annotation tool supports highlight, underline, strikethrough, and squiggly markup. The source now uses this viewer for selectable-text highlighting, color settings, and saving a separate edited PDF copy. The owner will perform the feature testing; the assistant has not run tests. [1] [2] [3]

The Syncfusion viewer is commercial software. Its current Community License eligibility requires less than US$1 million in annual gross revenue, five or fewer developers, ten or fewer employees, and no more than US$3 million in outside capital. Confirm eligibility and register the license before shipping. [4]

## Direct editing and conversion remain separate engine work

A highlight is a saved annotation over the page; it does not rewrite the source text. Adding an image is not the same operation as selecting and deleting an existing embedded image. The research did not establish a single Flutter SDK that provides arbitrary existing-text/image editing on both Android and Windows. Nutrient's Flutter content editor is documented for Android, but not as a Windows solution. Existing page rotation also uses `syncfusion_flutter_pdf`; its pub.dev platform listing does not establish Windows support, so treat Windows rotation persistence as unconfirmed until a suitable common engine is selected. [5] [6]

For Word conversion, investigate native Aspose.PDF integrations for Android and Windows separately. Its documented Word conversion trades visual resemblance against editability. Scanned PDFs need OCR before their text can become editable Word content. Adobe PDF Services is a possible cloud comparison, but its documented OCR-locale enum does not list Arabic; do not make it the Arabic scan path. [7] [8] [9]

For Excel conversion, use a PDF conversion engine to detect tables and cell structure; an XLSX writer alone is not an extractor. Aspose documents PDF-to-Excel on Android, while desktop/server options have different platform coverage. Syncfusion XlsIO can create workbooks and insert images, but it does not itself infer PDF tables. Excel is the sensible editable target for detected tables and structured data, not a guarantee that every page-design element becomes an editable spreadsheet cell. [10] [11] [12]

## Arabic and scanned documents

Prefer a usable embedded PDF text layer over OCR. For scans, evaluate local Tesseract with Arabic and English language data as an offline candidate, then allow correction when confidence is low. Google ML Kit Text Recognition's documented script list does not include Arabic. OCR recovers text and approximate locations; it does not reconstruct Word styles, tables, or reading order by itself. [13] [14] [15]

## Responsive phone and Windows interface

Use one shared editor state with adaptive composition: compact phone controls and contextual sheets, and a Windows layout with visible tools, page navigation, keyboard access, and optional side panels. Flutter's adaptive, accessibility, and internationalization guidance supports this approach. Keep interface RTL direction separate from document page order, and test mixed Arabic/Latin selection behavior with the owner. [16] [17] [18]

## Android update constraint

An in-place APK update must keep the same application ID, use a compatible signing certificate, and increase `versionCode`. Store the persistent signing key outside the repository as protected release secrets and maintain an encrypted backup. Without a connected device and a baseline APK or its trusted signing fingerprint, a build can be checked for its own signature but cannot prove it will update the owner's installed app. [19] [20] [21]

## References

[1]: https://pub.dev/packages/syncfusion_flutter_pdfviewer "Syncfusion Flutter PDF Viewer package and supported platforms"
[2]: https://help.syncfusion.com/document-processing/pdf/pdf-viewer/flutter/text-markup "Syncfusion text markup annotation guide"
[3]: https://pub.dev/documentation/syncfusion_flutter_pdfviewer/latest/pdfviewer/PdfViewerController-class.html "PdfViewerController saveDocument API"
[4]: https://www.syncfusion.com/products/communitylicense "Syncfusion Community License eligibility"
[5]: https://pub.dev/packages/syncfusion_flutter_pdf "Syncfusion Flutter PDF document package metadata"
[6]: https://www.nutrient.io/sdk/flutter/pdf-editing/ "Nutrient Flutter PDF content editing"
[7]: https://docs.aspose.com/pdf/androidjava/supported-file-formats/ "Aspose.PDF for Android supported formats"
[8]: https://docs.aspose.com/pdf/net/convert-pdf-to-word/ "Aspose.PDF for .NET PDF-to-Word modes"
[9]: https://opensource.adobe.com/pdfservices-node-sdk-samples/apidocs/latest/enums/ExportOCRLocale.html "Adobe PDF Services export OCR locales"
[10]: https://docs.aspose.com/pdf/androidjava/convert-pdf-to-excel/ "Aspose.PDF for Android PDF-to-Excel"
[11]: https://pub.dev/packages/syncfusion_flutter_xlsio "Syncfusion Flutter XlsIO workbook generation"
[12]: https://docs.apryse.com/documentation/core/guides/features/office/convert-to-office/ "Apryse desktop/server Office conversion"
[13]: https://github.com/espresso3389/pdfrx/blob/master/doc/Text-Selection.md "pdfrx text selection documentation"
[14]: https://tesseract-ocr.github.io/tessdoc/Installation.html "Tesseract installation and language data"
[15]: https://developers.google.com/ml-kit/vision/text-recognition/v2 "Google ML Kit supported scripts"
[16]: https://docs.flutter.dev/ui/adaptive-responsive "Flutter adaptive and responsive design"
[17]: https://docs.flutter.dev/ui/accessibility "Flutter accessibility guidance"
[18]: https://docs.flutter.dev/ui/internationalization "Flutter internationalization guidance"
[19]: https://developer.android.com/studio/publish/app-signing "Android app signing"
[20]: https://developer.android.com/studio/publish/versioning "Android app versioning"
[21]: https://docs.github.com/actions/security-guides/using-secrets-in-github-actions "GitHub Actions secrets guidance"


## User-image editing boundary

The current Syncfusion Flutter PDF Viewer feature list covers text markup but does not list custom image/stamp annotations. Syncfusion's Flutter issue response says custom stamp/image annotations are unsupported in its viewer. Its lower-level Flutter PDF package can draw JPEG/PNG content on a page, but that is not a complete move/resize/delete workflow for existing embedded image objects, and the package listing does not establish Windows support. Do not present the current highlighter as image editing. [22] [23]

[22]: https://github.com/syncfusion/flutter-widgets/issues/1958 "Syncfusion Flutter custom image/stamp annotation issue"
[23]: https://pub.dev/packages/syncfusion_flutter_pdf "Syncfusion Flutter PDF image drawing and document editing APIs"
