import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RedroPdfApp());
}

class RedroPdfApp extends StatefulWidget {
  const RedroPdfApp({super.key});

  @override
  State<RedroPdfApp> createState() => _RedroPdfAppState();
}

class _RedroPdfAppState extends State<RedroPdfApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _arabic = false;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE53935);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Redro PDF Converter',
      locale: Locale(_arabic ? 'ar' : 'en'),
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: red),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F6F7),
        appBarTheme: const AppBarTheme(centerTitle: false),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: red,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: ConverterHomePage(
        arabic: _arabic,
        onLanguageChanged: () => setState(() => _arabic = !_arabic),
        onThemeChanged: () => setState(() {
          _themeMode = _themeMode == ThemeMode.dark
              ? ThemeMode.light
              : ThemeMode.dark;
        }),
      ),
    );
  }
}

enum _ExportFormat { word, excel }

class _ConversionException implements Exception {
  const _ConversionException(this.message);
  final String message;
}

class ConverterHomePage extends StatefulWidget {
  const ConverterHomePage({
    super.key,
    required this.arabic,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  final bool arabic;
  final VoidCallback onLanguageChanged;
  final VoidCallback onThemeChanged;

  @override
  State<ConverterHomePage> createState() => _ConverterHomePageState();
}

class _ConverterHomePageState extends State<ConverterHomePage> {
  bool _busy = false;
  String? _status;
  String? _error;

  bool get _isArabic => widget.arabic;

  String _text(String english, String arabic) =>
      _isArabic ? arabic : english;

  Future<void> _convert(_ExportFormat format) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _status = _text('Choose a PDF file…', 'اختر ملف PDF…');
      _error = null;
    });

    sfpdf.PdfDocument? document;
    try {
      final selected = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (selected == null) return;
      final path = selected.path;
      if (path == null) {
        throw const _ConversionException(
          'Could not read the selected file from this device.',
        );
      }
      final sourceFile = File(path);
      if (!await sourceFile.exists() || await sourceFile.length() == 0) {
        throw const _ConversionException('The selected PDF is empty or unavailable.');
      }

      final inputBytes = await sourceFile.readAsBytes();
      document = sfpdf.PdfDocument(inputBytes: inputBytes);
      final pageCount = document.pages.count;
      if (pageCount == 0) {
        throw const _ConversionException('This PDF contains no pages.');
      }

      final extractor = sfpdf.PdfTextExtractor(document);
      final pages = <List<String>>[];
      var pagesWithoutText = 0;
      for (var pageIndex = 0; pageIndex < pageCount; pageIndex++) {
        if (!mounted) return;
        setState(() {
          _status = _text(
            'Reading page ${pageIndex + 1} of $pageCount…',
            'جارٍ قراءة الصفحة ${pageIndex + 1} من $pageCount…',
          );
        });
        final lines = extractor
            .extractTextLines(
              startPageIndex: pageIndex,
              endPageIndex: pageIndex,
            )
            .map((line) => line.text.trim())
            .where((line) => line.isNotEmpty)
            .toList(growable: false);
        if (lines.isEmpty) pagesWithoutText++;
        pages.add(lines);
      }

      if (pages.every((page) => page.isEmpty)) {
        throw _ConversionException(_text(
          'No selectable text was found. This PDF may be scanned images; OCR is not available yet.',
          'لم يتم العثور على نص قابل للاستخراج. قد يكون الملف صورًا ممسوحة ضوئيًا؛ ميزة OCR غير متاحة حاليًا.',
        ));
      }

      if (!mounted) return;
      setState(() {
        _status = format == _ExportFormat.word
            ? _text('Creating editable Word document…', 'جارٍ إنشاء ملف Word قابل للتحرير…')
            : _text('Creating editable Excel workbook…', 'جارٍ إنشاء ملف Excel قابل للتحرير…');
      });

      final baseName = _baseName(selected.name);
      final extension = format == _ExportFormat.word ? 'docx' : 'xlsx';
      final outputBytes = format == _ExportFormat.word
          ? _buildDocx(pages)
          : _buildXlsx(pages);
      final mimeType = format == _ExportFormat.word
          ? 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      final destination = await FilePicker.saveFile(
        dialogTitle: _text('Save converted file', 'حفظ الملف المحوّل'),
        fileName: '$baseName.$extension',
        bytes: outputBytes,
        mimeType: mimeType,
      );
      if (destination == null || !mounted) return;

      final skippedMessage = pagesWithoutText == 0
          ? ''
          : _text(
              ' $pagesWithoutText page(s) had no selectable text and were left empty.',
              ' تُركت $pagesWithoutText صفحة بلا نص قابل للاستخراج فارغة.',
            );
      setState(() {
        _status = _text(
          'Saved ${baseName}.$extension.$skippedMessage',
          'تم حفظ ${baseName}.$extension.$skippedMessage',
        );
      });
    } on _ConversionException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = _text(
            'Conversion failed. Check that this is a readable, unlocked PDF and try again.',
            'فشل التحويل. تأكد أن ملف PDF قابل للقراءة وغير محمي، ثم حاول مرة أخرى.',
          );
        });
      }
    } finally {
      document?.dispose();
      if (mounted) {
        setState(() {
          _busy = false;
          if (_error != null) _status = null;
        });
      }
    }
  }

  String _baseName(String fileName) {
    final name = fileName.toLowerCase().endsWith('.pdf')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;
    final cleaned = name.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    return cleaned.isEmpty ? 'converted_document' : cleaned;
  }

  Uint8List _buildXlsx(List<List<String>> pages) {
    final workbook = Excel.createExcel();
    workbook.rename('Sheet1', 'Extracted text');
    final sheet = workbook['Extracted text'];
    sheet.appendRow([
      TextCellValue('Page'),
      TextCellValue('Line'),
      TextCellValue('Extracted text'),
    ]);
    for (var pageIndex = 0; pageIndex < pages.length; pageIndex++) {
      final lines = pages[pageIndex];
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        sheet.appendRow([
          IntCellValue(pageIndex + 1),
          IntCellValue(lineIndex + 1),
          TextCellValue(lines[lineIndex]),
        ]);
      }
    }
    sheet.setColumnWidth(0, 10);
    sheet.setColumnWidth(1, 10);
    sheet.setColumnWidth(2, 80);
    final encoded = workbook.save();
    if (encoded == null || encoded.isEmpty) {
      throw const _ConversionException('Could not create the Excel workbook.');
    }
    return Uint8List.fromList(encoded);
  }

  Uint8List _buildDocx(List<List<String>> pages) {
    final body = StringBuffer();
    for (var pageIndex = 0; pageIndex < pages.length; pageIndex++) {
      if (pageIndex > 0) {
        body.write('<w:p><w:r><w:br w:type="page"/></w:r></w:p>');
      }
      body.write(_wordParagraph(
        _text('Page ${pageIndex + 1}', 'الصفحة ${pageIndex + 1}'),
        heading: true,
      ));
      for (final line in pages[pageIndex]) {
        body.write(_wordParagraph(line));
      }
    }

    const documentXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    BODY_CONTENT
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1134" w:right="1134" w:bottom="1134" w:left="1134" w:header="708" w:footer="708" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>''';

    final archive = Archive()
      ..addFile(ArchiveFile.string(
        '[Content_Types].xml',
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''',
      ))
      ..addFile(ArchiveFile.string(
        '_rels/.rels',
        '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''',
      ))
      ..addFile(ArchiveFile.string(
        'word/document.xml',
        documentXml.replaceFirst('BODY_CONTENT', body.toString()),
      ));
    final encoded = ZipEncoder().encode(archive);
    if (encoded == null || encoded.isEmpty) {
      throw const _ConversionException('Could not create the Word document.');
    }
    return Uint8List.fromList(encoded);
  }

  String _wordParagraph(String text, {bool heading = false}) {
    final isRtl = RegExp(r'[\u0590-\u08FF]').hasMatch(text);
    final paragraphProperties = isRtl
        ? '<w:pPr><w:bidi/><w:jc w:val="right"/></w:pPr>'
        : '';
    final runProperties = '<w:rPr>${isRtl ? '<w:rtl/>' : ''}${heading ? '<w:b/><w:sz w:val="30"/>' : ''}</w:rPr>';
    final escaped = const HtmlEscape(HtmlEscapeMode.text).convert(text);
    return '<w:p>$paragraphProperties<w:r>$runProperties<w:t xml:space="preserve">$escaped</w:t></w:r></w:p>';
  }

  Widget _formatCard({
    required _ExportFormat format,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _busy ? null : () => _convert(format),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(description, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isArabic = widget.arabic;
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage('assets/branding/redro_logo_mark.jpg'),
                width: 38,
                height: 38,
                fit: BoxFit.contain,
                semanticLabel: 'Redro PDF Converter',
              ),
              SizedBox(width: 8),
              Text('Redro PDF', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _busy ? null : widget.onLanguageChanged,
              child: Text(isArabic ? 'English' : 'العربية'),
            ),
            IconButton(
              tooltip: _text('Toggle appearance', 'تغيير المظهر'),
              onPressed: widget.onThemeChanged,
              icon: const Icon(Icons.contrast_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Image.asset(
                    'assets/branding/redro_logo.jpg',
                    height: 155,
                    fit: BoxFit.contain,
                    semanticLabel: 'Redro PDF Converter',
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _text('Convert PDF to an editable file', 'حوّل PDF إلى ملف قابل للتحرير'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _text('Choose the format you need. Your PDF stays on this device.', 'اختر الصيغة المطلوبة. يبقى ملف PDF على هذا الجهاز.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 22),
                _formatCard(
                  format: _ExportFormat.word,
                  icon: Icons.description_rounded,
                  title: _text('PDF to Word', 'PDF إلى Word'),
                  description: _text('Extract text into an editable .docx document', 'استخراج النص إلى مستند Word قابل للتحرير'),
                  color: const Color(0xFF185ABD),
                ),
                _formatCard(
                  format: _ExportFormat.excel,
                  icon: Icons.table_chart_rounded,
                  title: _text('PDF to Excel', 'PDF إلى Excel'),
                  description: _text('Put extracted lines into editable spreadsheet rows', 'وضع الأسطر المستخرجة في صفوف جدول قابلة للتحرير'),
                  color: const Color(0xFF188038),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _text(
                      'Text in the PDF is extracted locally. The Word layout may differ from the original. Excel receives one extracted text line per row; tables are not automatically reconstructed. Scanned-image pages need OCR, which is not included yet.',
                      'يُستخرج النص محليًا. قد يختلف تنسيق Word عن الأصل. يضع Excel كل سطر مستخرج في صف؛ ولا يعيد بناء الجداول تلقائيًا. الصفحات المصوّرة تحتاج OCR، وهي غير متاحة حاليًا.',
                    ),
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
                if (_busy) ...[
                  const SizedBox(height: 22),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 10),
                  Text(_status ?? _text('Working…', 'جارٍ العمل…'), textAlign: TextAlign.center),
                ] else if (_status != null) ...[
                  const SizedBox(height: 18),
                  Text(_status!, textAlign: TextAlign.center, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w700)),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: scheme.error)),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
