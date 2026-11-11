import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  final renderStopwatch = Stopwatch()..start();
  runApp(RedroPdfApp(
    initialPdfPath: _argumentValue(args, '--open-pdf'),
    smokeResultPath: _argumentValue(args, '--smoke-result'),
    smokeImagePath: _argumentValue(args, '--smoke-image'),
    renderStopwatch: renderStopwatch,
  ));
}

String? _argumentValue(List<String> args, String name) {
  final prefix = '$name=';
  for (final argument in args) {
    if (argument.startsWith(prefix)) return argument.substring(prefix.length);
  }
  return null;
}

class RedroPdfApp extends StatefulWidget {
  const RedroPdfApp({
    super.key,
    this.initialPdfPath,
    this.smokeResultPath,
    this.smokeImagePath,
    this.renderStopwatch,
  });

  final String? initialPdfPath;
  final String? smokeResultPath;
  final String? smokeImagePath;
  final Stopwatch? renderStopwatch;

  @override
  State<RedroPdfApp> createState() => _RedroPdfAppState();
}

class _RedroPdfAppState extends State<RedroPdfApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _arabic = false;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE53935);
    final colorScheme = ColorScheme.fromSeed(seedColor: red);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Redro PDF Editor & Converter',
      locale: Locale(_arabic ? 'ar' : 'en'),
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: colorScheme,
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
      home: PdfHomePage(
        arabic: _arabic,
        initialPdfPath: widget.initialPdfPath,
        smokeResultPath: widget.smokeResultPath,
        smokeImagePath: widget.smokeImagePath,
        renderStopwatch: widget.renderStopwatch,
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

class _OpenPdf {
  _OpenPdf({
    required this.path,
    required this.name,
    required this.pageCount,
    this.pageController,
    this.pinchController,
  });

  final String path;
  final String name;
  final int pageCount;
  final PdfController? pageController;
  final PdfControllerPinch? pinchController;
  int currentPage = 1;

  void dispose() {
    pageController?.dispose();
    pinchController?.dispose();
  }
}

class PdfHomePage extends StatefulWidget {
  const PdfHomePage({
    super.key,
    required this.arabic,
    this.initialPdfPath,
    this.smokeResultPath,
    this.smokeImagePath,
    this.renderStopwatch,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  final bool arabic;
  final String? initialPdfPath;
  final String? smokeResultPath;
  final String? smokeImagePath;
  final Stopwatch? renderStopwatch;
  final VoidCallback onLanguageChanged;
  final VoidCallback onThemeChanged;

  @override
  State<PdfHomePage> createState() => _PdfHomePageState();
}

class _PdfHomePageState extends State<PdfHomePage> {
  final List<_OpenPdf> _documents = [];
  final TextEditingController _pageInput = TextEditingController(text: '1');
  int _activeIndex = -1;
  String? _error;
  bool _busy = false;
  bool _smokeResultWritten = false;

  bool get _isArabic => widget.arabic;
  _OpenPdf? get _active =>
      _activeIndex >= 0 && _activeIndex < _documents.length
          ? _documents[_activeIndex]
          : null;

  String _text(String english, String arabic) => _isArabic ? arabic : english;

  @override
  void initState() {
    super.initState();
    final initialPath = widget.initialPdfPath;
    if (initialPath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_openPdf(initialPath: initialPath));
      });
    }
  }

  Future<void> _openPdf({String? initialPath}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final selected = initialPath == null
          ? await FilePicker.pickFile(
              type: FileType.custom,
              allowedExtensions: const ['pdf'],
            )
          : null;
      if (initialPath == null && selected == null) return;
      final path = initialPath ?? selected?.path;
      if (path == null) {
        throw const FormatException('The selected PDF has no readable local path.');
      }
      final name = selected?.name ?? File(path).uri.pathSegments.last;

      final existingIndex = _documents.indexWhere((item) => item.path == path);
      if (existingIndex >= 0) {
        if (mounted) {
          setState(() {
            _activeIndex = existingIndex;
            _pageInput.text = '${_documents[existingIndex].currentPage}';
          });
        }
        return;
      }

      final file = File(path);
      if (!await file.exists() || await file.length() == 0) {
        throw const FormatException('The selected file is empty or unavailable.');
      }

      final document = await PdfDocument.openFile(path);
      final controllerFuture = Future<PdfDocument>.value(document);
      final opened = Platform.isWindows
          ? _OpenPdf(
              path: path,
              name: name,
              pageCount: document.pagesCount,
              pageController: PdfController(document: controllerFuture),
            )
          : _OpenPdf(
              path: path,
              name: name,
              pageCount: document.pagesCount,
              pinchController: PdfControllerPinch(document: controllerFuture),
            );

      if (!mounted) {
        opened.dispose();
        return;
      }
      setState(() {
        _documents.add(opened);
        _activeIndex = _documents.length - 1;
        _pageInput.text = '1';
        _error = null;
      });
    } catch (error) {
      if (widget.smokeResultPath != null) {
        await _writeSmokeFailure(error);
      }
      if (mounted) {
        final detail = error is FormatException
            ? error.message
            : _text('Check that the file is a valid, unlocked PDF.',
                'تحقق من أن الملف PDF صالح وغير محمي بكلمة مرور.');
        setState(() => _error =
            '${_text('Could not open this PDF.', 'تعذّر فتح ملف PDF.')} $detail');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _selectDocument(int index) {
    setState(() {
      _activeIndex = index;
      _pageInput.text = '${_documents[index].currentPage}';
      _error = null;
    });
  }

  void _closeDocument(int index) {
    final closing = _documents.removeAt(index);
    closing.dispose();
    setState(() {
      if (_documents.isEmpty) {
        _activeIndex = -1;
      } else if (index < _activeIndex) {
        _activeIndex--;
      } else if (index == _activeIndex) {
        _activeIndex = index.clamp(0, _documents.length - 1).toInt();
      }
      final active = _active;
      _pageInput.text = active == null ? '1' : '${active.currentPage}';
    });
  }

  void _goToPage(int requestedPage) {
    final document = _active;
    if (document == null) return;
    final page = requestedPage.clamp(1, document.pageCount).toInt();
    if (document.pageController case final controller?) {
      controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    } else {
      document.pinchController!.animateToPage(
        pageNumber: page,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
    setState(() {
      document.currentPage = page;
      _pageInput.text = '$page';
    });
  }

  void _changePage(int amount) {
    final document = _active;
    if (document != null) _goToPage(document.currentPage + amount);
  }

  Widget _buildReader(_OpenPdf document) {
    final defaultPageBuilder = const PdfViewBuilders<DefaultBuilderOptions>(
      options: DefaultBuilderOptions(),
    ).pageBuilder;
    final builders = PdfViewBuilders<DefaultBuilderOptions>(
      options: const DefaultBuilderOptions(),
      pageBuilder: (context, pageImage, index, pdfDocument) {
        if (index == 0) {
          _recordFirstPageRender(pageImage, pdfDocument);
        }
        return defaultPageBuilder(context, pageImage, index, pdfDocument);
      },
      documentLoaderBuilder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
      pageLoaderBuilder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (_, error) => _readerError(error),
    );
    final pinchBuilders = PdfViewPinchBuilders<DefaultBuilderOptions>(
      options: const DefaultBuilderOptions(),
      documentLoaderBuilder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
      pageLoaderBuilder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (_, error) => _readerError(error),
    );

    if (document.pageController case final controller?) {
      return PdfView(
        key: ValueKey('pdf-${document.path}'),
        controller: controller,
        onPageChanged: (page) => _onPageChanged(document, page),
        builders: builders,
      );
    }
    return PdfViewPinch(
      key: ValueKey('pdf-${document.path}'),
      controller: document.pinchController!,
      onPageChanged: (page) => _onPageChanged(document, page),
      builders: pinchBuilders,
    );
  }

  Widget _readerError(Object error) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _text('This PDF page could not be rendered.', 'تعذّر عرض صفحة PDF هذه.'),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );

  void _onPageChanged(_OpenPdf document, int page) {
    document.currentPage = page;
    if (!mounted || !identical(document, _active)) return;
    setState(() => _pageInput.text = '$page');
  }

  Future<void> _writeSmokeFailure(Object error) async {
    final resultPath = widget.smokeResultPath;
    if (resultPath == null) return;
    final result = File(resultPath);
    await result.parent.create(recursive: true);
    await result.writeAsString(jsonEncode({
      'ok': false,
      'error': error.toString(),
      'timeToFirstPageImageMs': widget.renderStopwatch?.elapsedMilliseconds,
    }));
  }

  void _recordFirstPageRender(
    Future<PdfPageImage> pageImage,
    PdfDocument document,
  ) {
    final resultPath = widget.smokeResultPath;
    if (resultPath == null || _smokeResultWritten) return;
    _smokeResultWritten = true;
    unawaited(pageImage.then<void>((image) async {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final imagePath = widget.smokeImagePath;
      if (imagePath != null) {
        final renderedImage = File(imagePath);
        await renderedImage.parent.create(recursive: true);
        await renderedImage.writeAsBytes(image.bytes, flush: true);
      }
      final result = File(resultPath);
      await result.parent.create(recursive: true);
      await result.writeAsString(jsonEncode({
        'ok': true,
        'pageCount': document.pagesCount,
        'renderedPage': image.pageNumber,
        'imageWidth': image.width,
        'imageHeight': image.height,
        'imageBytes': image.bytes.length,
        'timeToFirstPageImageMs':
            widget.renderStopwatch?.elapsedMilliseconds,
      }));
    }).catchError((Object error) async {
      await _writeSmokeFailure(error);
    }));
  }

  Widget _buildDocumentTab(int index, _OpenPdf document) {
    final selected = index == _activeIndex;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.secondaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectDocument(index),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.picture_as_pdf_rounded,
                    size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 190),
                  child: Text(
                    document.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _text('Close document', 'إغلاق المستند'),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _closeDocument(index),
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.picture_as_pdf_rounded,
                    size: 52, color: scheme.primary),
              ),
              const SizedBox(height: 22),
              Text(
                _text('Your PDFs, ready to read.', 'ملفات PDF جاهزة للقراءة.'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                _text(
                  'Open documents stored on this device. Your files are not uploaded.',
                  'افتح المستندات المخزنة على هذا الجهاز. لا يتم رفع ملفاتك.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _busy ? null : _openPdf,
                icon: const Icon(Icons.folder_open_rounded),
                label: Text(_busy
                    ? _text('Opening…', 'جارٍ الفتح…')
                    : _text('Open PDF', 'فتح ملف PDF')),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final document in _documents) {
      document.dispose();
    }
    _pageInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final document = _active;
    final isArabic = widget.arabic;
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFE53935)),
              SizedBox(width: 8),
              Text('Redro PDF', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
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
            if (document != null)
              IconButton(
                tooltip: _text('Open another PDF', 'فتح ملف آخر'),
                onPressed: _busy ? null : _openPdf,
                icon: const Icon(Icons.add_rounded),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: document == null
            ? _buildEmptyState(context)
            : Column(
                children: [
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 54,
                          child: ListView.builder(
                            padding: const EdgeInsetsDirectional.only(
                              start: 16,
                              end: 8,
                              top: 6,
                              bottom: 6,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: _documents.length,
                            itemBuilder: (context, index) => _buildDocumentTab(
                              index,
                              _documents[index],
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        SizedBox(
                          height: 54,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                tooltip: _text('Previous page', 'الصفحة السابقة'),
                                onPressed: document.currentPage > 1
                                    ? () => _changePage(-1)
                                    : null,
                                icon: const Icon(Icons.chevron_left_rounded),
                              ),
                              SizedBox(
                                width: 68,
                                child: TextField(
                                  key: ValueKey('page-${document.path}'),
                                  controller: _pageInput,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onSubmitted: (value) {
                                    final page = int.tryParse(value);
                                    if (page != null) {
                                      _goToPage(page);
                                    } else {
                                      _pageInput.text = '${document.currentPage}';
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '/ ${document.pageCount}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: _text('Next page', 'الصفحة التالية'),
                                onPressed:
                                    document.currentPage < document.pageCount
                                        ? () => _changePage(1)
                                        : null,
                                icon: const Icon(Icons.chevron_right_rounded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null)
                    MaterialBanner(
                      content: Text(_error!),
                      leading: const Icon(Icons.error_outline_rounded),
                      actions: [
                        TextButton(
                          onPressed: () => setState(() => _error = null),
                          child: Text(_text('Dismiss', 'إغلاق')),
                        ),
                      ],
                    ),
                  Expanded(child: _buildReader(document)),
                ],
              ),
        floatingActionButton: document == null
            ? null
            : FloatingActionButton.small(
                tooltip: _text('Open another PDF', 'فتح ملف آخر'),
                onPressed: _busy ? null : _openPdf,
                child: const Icon(Icons.add_rounded),
              ),
      ),
    );
  }
}
