import 'package:drive_memo/screens/home_screen.dart';
import 'package:drive_memo/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drive_memo/main.dart';

void main() {
  testWidgets('Splash Screen Display and Navigation Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the SplashScreen is shown first.
    expect(find.byType(SplashScreen), findsOneWidget);

    // SplashScreen automatically navigates to the HomeScreen after some delay,
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(HomeScreen), findsOneWidget);

      final homeButton = find.byKey(const Key('homeScreenButton'));
    if (homeButton.evaluate().isNotEmpty) {
      await tester.tap(homeButton);
      await tester.pumpAndSettle(); // Wait for the animation to complete
      expect(find.byType(HomeScreen), findsOneWidget);
    }
  });
}
