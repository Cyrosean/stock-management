// Basic smoke test for the Wholesale Inventory app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wholesale_app/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const WholesaleApp());

    expect(find.text('Wholesale Inventory'), findsOneWidget);
    expect(find.byIcon(Icons.warehouse), findsOneWidget);
  });
}
