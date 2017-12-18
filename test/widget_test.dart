// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crackling_spark/main.dart';

void main() {
  testWidgets('Sending a message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(new CracklingsparkApp());

    // Verify that our counter starts at 0.
    expect(find.text('Crackling Spark'), findsOneWidget);
    expect(find.text('Your Name'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.enterText(find.byType(TextField), "Texting woohoo!");
    await tester.tap(find.byIcon(Icons.send));

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    //awat (find.text('Texting woohoo!'), findsOneWidget);
  });
}
