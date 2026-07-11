import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alu_hub/features/screens/login_screen.dart';

void main() {
  group('ALU Hub Login Screen Tests', () {
    testWidgets('Login screen shows the required information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.text('Welcome Back'), findsOneWidget);

      expect(
        find.text('Sign in to discover ALU startup opportunities.'),
        findsOneWidget,
      );

      expect(find.text('Email'), findsOneWidget);

      expect(find.text('Password'), findsOneWidget);

      expect(find.byType(TextFormField), findsNWidgets(2));

      expect(find.text('Forgot password?'), findsOneWidget);

      expect(find.text('Create account'), findsOneWidget);
    });

    testWidgets('Login form shows errors when fields are empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      final signInButton = find.widgetWithText(FilledButton, 'Sign In');

      expect(signInButton, findsOneWidget);

      await tester.tap(signInButton);
      await tester.pump();

      expect(find.text('Please enter your email address'), findsOneWidget);

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Password visibility button is available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
