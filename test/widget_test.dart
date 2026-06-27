import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Notification page renders Smart Farm alerts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: NotificationPage()));

    expect(find.text('NOTIFIKASI'), findsOneWidget);
    expect(find.text('SAWAH BANJIR'), findsOneWidget);
    expect(find.text('KONDISI NORMAL'), findsOneWidget);
  });
}
