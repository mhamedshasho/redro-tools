import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redro_pdf/main.dart';

void main() {
  testWidgets('home screen offers Word and Excel conversion choices',
      (tester) async {
    await tester.pumpWidget(const RedroPdfApp());

    expect(find.text('Redro PDF'), findsOneWidget);
    expect(find.text('Convert PDF to an editable file'), findsOneWidget);
    expect(find.text('PDF to Word'), findsOneWidget);
    expect(find.text('PDF to Excel'), findsOneWidget);
    expect(find.text('Text in the PDF is extracted locally.'), findsNothing);
  });

  testWidgets('language control switches converter labels to Arabic',
      (tester) async {
    await tester.pumpWidget(const RedroPdfApp());

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    expect(find.text('حوّل PDF إلى ملف قابل للتحرير'), findsOneWidget);
    expect(find.text('PDF إلى Word'), findsOneWidget);
    expect(find.text('PDF إلى Excel'), findsOneWidget);
    expect(
      tester.widget<Directionality>(find.byType(Directionality).last).textDirection,
      TextDirection.rtl,
    );
  });

  testWidgets('appearance control toggles dark and light themes',
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
