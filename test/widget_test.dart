// This is a basic Flutter widget test for Course Users App
//
// This test verifies that the app can build successfully and displays
// the correct title for the Student & Parent Portal.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:course_users/main.dart';

void main() {
  testWidgets('CourseUsersApp builds successfully',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: CourseUsersApp(),
      ),
    );

    // Verify that the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);

    // The app should show a loading state or splash screen initially
    // Since we don't have Supabase initialized in tests, it may show login or error
  });

  testWidgets('App displays correct title', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      const ProviderScope(
        child: CourseUsersApp(),
      ),
    );

    // Verify app title is set correctly in MaterialApp
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, 'Course Users - Student & Parent Portal');
  });
}
