import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

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
      title: 'Redro PDF',
      locale: Locale(_arabic ? 'ar' : 'en'),
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: red, brightness: Brightness.light),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: red, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: PdfHomePage(
        arabic: _arabic,
        onLanguageChanged: () => setState(() => _arabic = !_arabic),
        onThemeChanged: () => setState(() {
          _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        }),
      ),
    );
  }
}

class PdfHomePage extends StatefulWidget {
  const PdfHomePage({
    super.key,
    required this.arabic,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  final bool arabic;
  final VoidCallback onLanguageChanged;
  final VoidCallback onThemeChanged;

  @override
  State<PdfHomePage> createState() => _PdfHomePageState();
}

class _PdfHomePageState extends State<PdfHomePage> {
  PdfControllerPinch? _controller;
  String? _fileName;
  String? _error;
  bool _busy = false;

  String get _openLabel => widget.arabic ? 'فتح ملف PDF' : 'Open PDF';

  Future<void> _openPdf() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
      );
      if (result == null || result.files.single.path == null) return;
      final path = result.files.single.path!;
      final file = File(path);
      if (!await file.exists() || await file.length() == 0) {
        throw Exception('Invalid PDF');
      }
      final next = PdfControllerPinch(document: PdfDocument.openFile(path));
      final previous = _controller;
      if (!mounted) {
        next.dispose();
        return;
      }
      setState(() {
        _controller = next;
        _fileName = result.files.single.name;
      });
      previous?.dispose();
    } catch (_) {
      if (mounted) {
        setState(() => _error = widget.arabic
            ? 'تعذّر فتح الملف. جرّب ملف PDF آخر.'
            : 'Could not open this PDF. Please try another file.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPdf = _controller != null;
    final isArabic = widget.arabic;
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Redro PDF', style: TextStyle(fontWeight: FontWeight.w800)),
          actions: [
            TextButton(
              onPressed: widget.onLanguageChanged,
              child: Text(isArabic ? 'English' : 'العربية'),
            ),
            IconButton(
              tooltip: isArabic ? 'تغيير المظهر' : 'Toggle appearance',
              onPressed: widget.onThemeChanged,
              icon: const Icon(Icons.contrast_rounded),
            ),
            if (hasPdf)
              IconButton(
                tooltip: isArabic ? 'فتح ملف آخر' : 'Open another PDF',
                onPressed: _busy ? null : _openPdf,
                icon: const Icon(Icons.folder_open_rounded),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            if (_fileName != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Text(_fileName!, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            Expanded(
              child: hasPdf
                  ? PdfViewPinch(
                      controller: _controller!,
                      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                        options: const DefaultBuilderOptions(),
                        documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                        pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
                        errorBuilder: (_, error) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(isArabic ? 'تعذّر عرض هذه الصفحة.' : 'Unable to render this page.'),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.picture_as_pdf_rounded,
                                size: 76, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(height: 18),
                            Text(
                              isArabic ? 'افتح واقرأ ملفات PDF' : 'Open and read PDF files',
                              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isArabic ? 'تبقى مستنداتك على جهازك.' : 'Your documents stay on your device.',
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 22),
                            FilledButton.icon(
                              onPressed: _busy ? null : _openPdf,
                              icon: const Icon(Icons.folder_open_rounded),
                              label: Text(_busy
                                  ? (isArabic ? 'جارٍ الفتح…' : 'Opening…')
                                  : _openLabel),
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 14),
                              Text(_error!, textAlign: TextAlign.center,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: hasPdf
            ? FloatingActionButton.extended(
                onPressed: _openPdf,
                icon: const Icon(Icons.folder_open_rounded),
                label: Text(_openLabel),
              )
            : null,
      ),
    );
  }
}
