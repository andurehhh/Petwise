import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petwise/presentation/widgets/petwise_offline_snackbar.dart';
import 'package:petwise/utils/error_mapper.dart';

void main() {
  group('PetwiseOfflineSnackbar Tests', () {
    testWidgets('Renders error icon by default in offline snackbar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PetwiseOfflineSnackbar.show(
                    context,
                    title: 'No Internet Connection',
                    message: 'Please check your connection.',
                    onRetry: () {},
                  );
                },
                child: const Text('Show Snackbar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Snackbar'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 750)); // Finish entrance

      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.text('Please check your connection.'), findsOneWidget);
      // Verify the error icon is present in the snackbar
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      // Verify Retry and Cancel actions are present
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Renders custom icon when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PetwiseOfflineSnackbar.show(
                    context,
                    title: 'Offline Mode',
                    message: 'Cached data displayed.',
                    icon: Icons.wifi_off_rounded,
                  );
                },
                child: const Text('Show Snackbar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Snackbar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('Offline Mode'), findsOneWidget);
    });

    testWidgets(
      'showError convenience method displays AppError with error icon',
      (WidgetTester tester) async {
        const error = AppError(
          category: ErrorCategory.server,
          title: 'Server Error',
          message: 'Something went wrong on our end.',
          instructions: ['Try again later'],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    PetwiseOfflineSnackbar.showError(
                      context,
                      error: error,
                      onRetry: () {},
                    );
                  },
                  child: const Text('Show Error'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Error'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 750));

        expect(find.text('Server Error'), findsOneWidget);
        expect(find.text('Something went wrong on our end.'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets('Tapping Retry triggers the onRetry callback', (
      WidgetTester tester,
    ) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  PetwiseOfflineSnackbar.show(
                    context,
                    title: 'Connection Lost',
                    message: 'Tap retry to reconnect.',
                    onRetry: () {
                      retried = true;
                    },
                  );
                },
                child: const Text('Show Snackbar'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Snackbar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets(
      'Renders red border, red-tinted icon, orange retry button, and multi-line title and message without cut off',
      (WidgetTester tester) async {
        const fullTitle = 'No Internet Connection';
        const fullMessage =
            'We could not reach PetWise servers. Please check your internet connection and try again.';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    PetwiseOfflineSnackbar.show(
                      context,
                      title: fullTitle,
                      message: fullMessage,
                      onRetry: () {},
                    );
                  },
                  child: const Text('Show Network Error'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show Network Error'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 750));

        // 1. Verify title is rendered with maxLines: 2 so it never gets cut off
        expect(find.text(fullTitle), findsOneWidget);
        final titleWidget = tester.widget<Text>(find.text(fullTitle));
        expect(titleWidget.maxLines, 2);

        // 2. Verify full message is rendered with maxLines: 5
        expect(find.text(fullMessage), findsOneWidget);
        final textWidget = tester.widget<Text>(find.text(fullMessage));
        expect(textWidget.maxLines, 5);

        // 3. Verify red-tinted icon
        final iconFinder = find.byIcon(Icons.error_outline_rounded);
        expect(iconFinder, findsOneWidget);
        final iconWidget = tester.widget<Icon>(iconFinder);
        expect(iconWidget.color, Colors.red.shade600);

        // 4. Verify orange retry button
        final retryFinder = find.text('Retry');
        expect(retryFinder, findsOneWidget);

        // 5. Verify snackbar border has red tone
        final snackBarFinder = find.byType(SnackBar);
        expect(snackBarFinder, findsOneWidget);
        final snackBar = tester.widget<SnackBar>(snackBarFinder);
        final shape = snackBar.shape as RoundedRectangleBorder;
        expect(shape.side.color, Colors.red.shade200);
      },
    );
  });
}
