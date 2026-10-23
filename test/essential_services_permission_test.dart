import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:petwise/data/models/activity_model.dart';
import 'package:petwise/presentation/screens/essential_services_screen.dart';
import 'package:petwise/providers/essential_services_provider.dart';
import 'package:petwise/providers/activity_provider.dart';

class MockActivityProvider extends ChangeNotifier implements ActivityProvider {
  @override
  List<ActivityModel> get activities => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestEssentialServicesProvider extends EssentialServicesProvider {
  bool _mockIsLoading = false;
  bool _mockHasAttemptedLocation = true;

  void setLoading(bool loading) {
    _mockIsLoading = loading;
    notifyListeners();
  }

  void setHasAttemptedLocation(bool attempted) {
    _mockHasAttemptedLocation = attempted;
    notifyListeners();
  }

  @override
  bool get isLoading => _mockIsLoading;

  @override
  bool get hasAttemptedLocation => _mockHasAttemptedLocation;

  @override
  Future<void> initLocationAndFetch({dynamic onMarkerTap}) async {
    // No-op in widget test to avoid platform channel Geolocator call
  }
}

void main() {
  group('EssentialServicesScreen Permission Denied UI Tests', () {
    testWidgets(
      'Renders prompt to re-enable location in app settings and retry button when location is denied',
      (WidgetTester tester) async {
        final provider = TestEssentialServicesProvider();
        final activityProvider = MockActivityProvider();

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<EssentialServicesProvider>.value(
                value: provider,
              ),
              ChangeNotifierProvider<ActivityProvider>.value(
                value: activityProvider,
              ),
            ],
            child: const MaterialApp(home: EssentialServicesScreen()),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Verify permission prompt is rendered instead of an indefinite spinner
        expect(find.text('Location Permission Required'), findsOneWidget);
        expect(
          find.textContaining(
            'Please re-enable location permission via your app settings',
          ),
          findsOneWidget,
        );

        // Verify "Open App Settings" button exists
        expect(find.text('Open App Settings'), findsOneWidget);

        // Verify "Retry" button exists
        expect(find.text('Retry'), findsOneWidget);

        // Verify emergency hotlines link exists
        expect(find.text('View Emergency Hotlines'), findsOneWidget);

        // Verify no infinite loading spinner is left running
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'Shows loading indicator while location is being requested and switches to prompt when done without location',
      (WidgetTester tester) async {
        final provider = TestEssentialServicesProvider();
        final activityProvider = MockActivityProvider();
        provider.setLoading(true);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<EssentialServicesProvider>.value(
                value: provider,
              ),
              ChangeNotifierProvider<ActivityProvider>.value(
                value: activityProvider,
              ),
            ],
            child: const MaterialApp(home: EssentialServicesScreen()),
          ),
        );

        await tester.pump();

        // When loading, spinner with "Accessing location..." is shown
        expect(find.text('Accessing location...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Finish loading without location (denied)
        provider.setLoading(false);
        await tester.pump();

        // Now the permission required card is shown
        expect(find.text('Location Permission Required'), findsOneWidget);
        expect(find.text('Open App Settings'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });
}
