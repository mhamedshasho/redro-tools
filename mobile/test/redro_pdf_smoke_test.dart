import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redro_pdf/main.dart';

void main() {
  testWidgets('home screen presents the local PDF reader', (tester) async {
    await tester.pumpWidget(const RedroPdfApp());

    expect(find.text('Redro PDF'), findsOneWidget);
    expect(find.text('Your PDFs, ready to read.'), findsOneWidget);
    expect(find.text('Open PDF'), findsOneWidget);
    expect(
      find.text('Open documents stored on this device. Your files are not uploaded.'),
      findsOneWidget,
    );
  });

  testWidgets('language control switches the reader copy to Arabic', (tester) async {
    await tester.pumpWidget(const RedroPdfApp());

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(find.text('ملفات PDF جاهزة للقراءة.'), findsOneWidget);
    expect(find.text('فتح ملف PDF'), findsOneWidget);
    expect(
      tester.widget<Directionality>(find.byType(Directionality).last).textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('appearance control cycles from system to dark and light',
      (tester) async {
    await tester.pumpWidget(const RedroPdfApp());

    await tester.tap(find.byTooltip('Toggle appearance'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tester.tap(find.byTooltip('Toggle appearance'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });
}
