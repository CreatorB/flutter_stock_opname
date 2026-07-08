import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke test renders a widget tree', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Flutter Stock Opname'),
        ),
      ),
    );

    expect(find.text('Flutter Stock Opname'), findsOneWidget);
  });
}
