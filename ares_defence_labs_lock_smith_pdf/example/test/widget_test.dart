import 'package:flutter_test/flutter_test.dart';

import 'package:ares_defence_labs_lock_smith_pdf_example/main.dart';

void main() {
  testWidgets('shows the PDF actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Plugin example app'), findsOneWidget);
    expect(find.text('Encrypt PDF'), findsOneWidget);
    expect(find.text('Encrypt PDF with Permissions'), findsOneWidget);
    expect(find.text('Decrypt PDF'), findsOneWidget);
  });
}
