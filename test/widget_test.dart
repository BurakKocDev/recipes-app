// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recipes/main.dart';

void main() {
  testWidgets('Recipe app builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RecipeApp());
    await tester.pump(); // Initial build

    // Verify that the app bar title is displayed
    expect(find.text('Recipe Finder'), findsOneWidget);
  });

  testWidgets('Recipe app displays app bar', (WidgetTester tester) async {
    await tester.pumpWidget(const RecipeApp());
    await tester.pump(); // Initial build

    // Verify that the app bar is present
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Recipe Finder'), findsOneWidget);
  });
}
