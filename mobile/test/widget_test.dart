import 'package:flutter_test/flutter_test.dart';
import 'package:redro_pdf/main.dart';

void main() {
  testWidgets('Redro PDF home screen renders', (tester) async {
    await tester.pumpWidget(const RedroPdfApp());
    expect(find.text('Redro PDF'), findsOneWidget);
    expect(find.text('Open and read PDF files'), findsOneWidget);
    expect(find.text('Open PDF'), findsOneWidget);
  });
}
