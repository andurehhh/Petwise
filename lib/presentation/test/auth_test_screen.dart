import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:petwise/contracts/activity/create_activity_request.dart';
import 'package:petwise/contracts/activity/update_activity_request.dart';
import 'package:petwise/contracts/analytics/pet_activity_health_analytics_response.dart';
import 'package:petwise/contracts/analytics/user_dashboard_analytics_response.dart';
import 'package:petwise/contracts/auth/signin_request.dart';
import 'package:petwise/contracts/auth/signup_request.dart';
import 'package:petwise/contracts/pet/update_pet_request.dart';
import 'package:petwise/contracts/user/update_user_request.dart';
import 'package:petwise/contracts/health_event/create_health_event_request.dart';
import 'package:petwise/contracts/health_event/health_event_response.dart';
import 'package:petwise/services/health_event_service.dart';
import 'package:petwise/services/activity_service.dart';
import 'package:petwise/services/api_client.dart';
import 'package:petwise/services/auth_service.dart';
import 'package:petwise/services/pet_service.dart';
import 'package:petwise/services/user_service.dart';

import 'package:petwise/services/analytics_service.dart';

class AuthTestScreen extends StatefulWidget {
  const AuthTestScreen({super.key});
  @override
  State<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends State<AuthTestScreen> {
  String _output = 'No result yet';
  String? _userId;

  final _apiClient = ApiClient();
  late final _auth = AuthService(_apiClient);
  late final _pet = PetService(_apiClient);
  late final _user = UserService(_apiClient);
  late final _activity = ActivityService(_apiClient);
  late final _healthEvent = HealthEventService(_apiClient);
  late final _analytics = AnalyticsService(_apiClient);

  int? _lastActivityId = 6;
  int? _lastHealthEventId;

  // SIGNIN
  Future<void> _testSignIn() async {
    try {
      final result = await _auth.signIn(
        SignInRequest(email: 'renzosua111@gmail.com', password: 'renzo1234'),
      );
      setState(() {
        _userId = result.userId;
        _output =
            'SIGN IN SUCCESS:\nEmail: ${result.email}\nUserID: ${result.userId}\nToken: ${result.accessToken}';
      });
    } catch (e) {
      setState(() => _output = 'SIGN IN ERROR: $e');
    }
  }

  // GOOGLE SIGN IN
  Future<void> _testGoogleSignIn() async {
    try {
      final result = await _auth.signInWithGoogle();
      setState(() {
        _userId = result.userId;
        _output =
            'GOOGLE SIGN IN SUCCESS:\nEmail: ${result.email}\nUserID: ${result.userId}\nToken: ${result.accessToken}';
      });
    } catch (e) {
      setState(() => _output = 'GOOGLE SIGN IN ERROR: $e');
    }
  }

  // SIGNUP
  Future<void> _testSignUp() async {
    try {
      final result = await _auth.signUp(
        SignUpRequest(email: 'testuser@gmail.com', password: 'test1234'),
      );
      setState(() => _output = 'SIGN UP SUCCESS:\n${result.toString()}');
    } catch (e) {
      setState(() => _output = 'SIGN UP ERROR: $e');
    }
  }

  // CHANGE PASSWORD
  Future<void> _testChangePassword() async {
    try {
      final result = await _auth.changePassword(
        email: 'renzosua111@gmail.com',
        currentPassword: 'renzo072',
        newPassword: 'renzo1234',
      );
      setState(
        () => _output = 'CHANGE PASSWORD SUCCESS:\n${result.toString()}',
      );
    } catch (e) {
      setState(() => _output = 'CHANGE PASSWORD ERROR: $e');
    }
  }

  // GET PET BY USER ID
  Future<void> _testGetPets() async {
    if (_userId == null) {
      setState(() => _output = 'ERROR: Sign in first to get a userId');
      return;
    }
    try {
      final result = await _pet.getPetsByUser(_userId!);
      setState(
        () => _output =
            'GET PETS SUCCESS:\n${result.map((p) => p.toJson()).toList()}',
      );
    } catch (e) {
      setState(() => _output = 'GET PETS ERROR: $e');
    }
  }

  // GET PET BY PET ID
  Future<void> _testGetPet2() async {
    try {
      final result = await _pet.getPet(4);
      setState(() => _output = 'GET PET SUCCESS:\n${result.toJson()}');
    } catch (e) {
      setState(() => _output = 'GET PET ERROR: $e');
    }
  }

  // UPDATE PET
  Future<void> _testUpdatePet() async {
    try {
      final result = await _pet.updatePet(
        4,
        UpdatePetRequest(
          name: 'Mhing Mhing',
          species: 'Cat',
          birthday: DateTime(2020, 1, 1),
          sex: 'Male',
          breed: 'Guy',
          weight: 10.5,
        ),
      );
      setState(() => _output = 'UPDATE PET SUCCESS:\n${result.toJson()}');
    } catch (e) {
      setState(() => _output = 'UPDATE PET ERROR: $e');
    }
  }

  // DELETE PET
  Future<void> _testDeletePet() async {
    try {
      await _pet.deletePet(5);
      setState(() => _output = 'DELETE PET SUCCESS');
    } catch (e) {
      setState(() => _output = 'DELETE PET ERROR: $e');
    }
  }

  // USER INFO USING USER ID
  Future<void> _testGetUser() async {
    if (_userId == null) {
      setState(() => _output = 'ERROR: Sign in first to get a userId');
      return;
    }
    try {
      final result = await _user.getUser(_userId!);
      setState(() => _output = 'GET USER SUCCESS:\n${result.toJson()}');
    } catch (e) {
      setState(() => _output = 'GET USER ERROR: $e');
    }
  }

  // UPDATE USER INFOs
  Future<void> _testUpdateUser() async {
    if (_userId == null) {
      setState(() => _output = 'ERROR: Sign in first to get a userId');
      return;
    }
    try {
      final result = await _user.updateUser(
        _userId!,
        UpdateUserRequest(nickname: 'RENZLY'),
      );
      setState(() => _output = 'UPDATE USER SUCCESS:\n${result.toJson()}');
    } catch (e) {
      setState(() => _output = 'UPDATE USER ERROR: $e');
    }
  }

  Future<void> _testCreateActivity() async {
    try {
      final resultId = await _activity.createActivity(
        CreateActivityRequest(
          petId: 4,
          title: 'Daily Walk',
          description: 'Walk around the village park',
          timeScheduled: '17:00:00',
          recurrence: 'Daily',
        ),
      );
      setState(() {
        _lastActivityId = resultId;
        _output = 'CREATE ACTIVITY SUCCESS:\nCreated ID: $resultId';
      });
    } catch (e) {
      setState(() => _output = 'CREATE ACTIVITY ERROR: $e');
    }
  }

  // GET ACTIVITY BY ID
  Future<void> _testGetActivity() async {
    if (_lastActivityId == null) {
      setState(() => _output = 'ERROR: Create an activity first to get an ID');
      return;
    }
    try {
      final result = await _activity.getActivity(_lastActivityId!);
      setState(() => _output = 'GET ACTIVITY SUCCESS:\n${result.toJson()}');
    } catch (e) {
      setState(() => _output = 'GET ACTIVITY ERROR: $e');
    }
  }

  // UPDATE ACTIVITY
  Future<void> _testUpdateActivity() async {
    if (_lastActivityId == null) {
      setState(() => _output = 'ERROR: Create an activity first to update');
      return;
    }
    try {
      final result = await _activity.patchActivity(
        _lastActivityId!,
        UpdateActivityRequest(
          title: 'Updated Walk Time',
          timeScheduled: '18:30:00',
          isActive: false,
        ),
      );
      setState(() => _output = 'UPDATE ACTIVITY SUCCESS:\n${result.toJson()}');
    } catch (e) {
      setState(() => _output = 'UPDATE ACTIVITY ERROR: $e');
    }
  }

  // DELETE ACTIVITY
  Future<void> _testDeleteActivity() async {
    if (_lastActivityId == null) {
      setState(() => _output = 'ERROR: Create an activity first to delete');
      return;
    }
    try {
      final message = await _activity.deleteActivity(_lastActivityId!);
      setState(() {
        _output = 'DELETE SUCCESS: $message';
        _lastActivityId = null;
      });
    } catch (e) {
      setState(() => _output = 'DELETE ACTIVITY ERROR: $e');
    }
  }

  // HEALTH EVENTS TEST METHODS
  Future<void> _testCreateHealthEvent() async {
    try {
      final resultId = await _healthEvent.createHealthEvent(
        CreateHealthEventRequest(
          petId: 6,
          eventName: 'Rabies Booster Shot',
          eventDate: DateTime.now().add(const Duration(days: 7)),
          type: 'vaccination',
        ),
      );
      setState(() {
        _lastHealthEventId = resultId;
        _output = 'CREATE HEALTH EVENT SUCCESS:\nCreated Event ID: $resultId';
      });
    } catch (e) {
      setState(() => _output = 'CREATE HEALTH EVENT ERROR: $e');
    }
  }

  Future<void> _testGetHealthEventById() async {
    if (_lastHealthEventId == null) {
      setState(
        () => _output = 'ERROR: Create a health event first to get its ID',
      );
      return;
    }
    try {
      final result = await _healthEvent.getHealthEvent(_lastHealthEventId!);
      setState(() => _output = 'GET HEALTH EVENT SUCCESS:\n${result.toJson()}');
    } catch (e) {
      setState(() => _output = 'GET HEALTH EVENT ERROR: $e');
    }
  }

  Future<void> _testGetHealthEventsByPet() async {
    try {
      final List<HealthEventResponse> results = await _healthEvent
          .getHealthEventsByPet(6);
      setState(() {
        _output =
            'GET HEALTH EVENTS BY PET SUCCESS:\n'
            '${results.map((e) => e.toJson()).toList()}';
      });
    } catch (e) {
      setState(() => _output = 'GET HEALTH EVENTS BY PET ERROR: $e');
    }
  }

  Future<void> _testCompleteHealthEvent() async {
    if (_lastHealthEventId == null) {
      setState(
        () => _output = 'ERROR: Create a health event first to mark complete',
      );
      return;
    }
    try {
      final message = await _healthEvent.completeHealthEvent(
        _lastHealthEventId!,
      );
      setState(() => _output = 'COMPLETE HEALTH EVENT SUCCESS:\n$message');
    } catch (e) {
      setState(() => _output = 'COMPLETE HEALTH EVENT ERROR: $e');
    }
  }

  Future<void> _testDeleteHealthEvent() async {
    if (_lastHealthEventId == null) {
      setState(
        () => _output = 'ERROR: Create a health event first to delete it',
      );
      return;
    }
    try {
      final message = await _healthEvent.deleteHealthEvent(_lastHealthEventId!);
      setState(() {
        _output = 'DELETE HEALTH EVENT SUCCESS:\n$message';
        _lastHealthEventId = null;
      });
    } catch (e) {
      setState(() => _output = 'DELETE HEALTH EVENT ERROR: $e');
    }
  }

  // ANALYTICS TEST METHODS

  Future<void> _testGetPetAnalytics() async {
    try {
      // Targets Pet ID 6 (matches your health event dashboard tests)
      final PetActivityHealthAnalyticsResponse metrics = await _analytics
          .getPetAnalytics(12);

      setState(() {
        _output =
            'GET PET ANALYTICS SUCCESS:\n'
            'Activities: ${metrics.totalScheduledActivities}\n'
            'Active Routines: ${metrics.totalActiveRoutines}\n'
            'Monthly Health Events: ${metrics.totalHealthEvents}\n'
            'Compliance Rate: ${metrics.medicalComplianceRate}%\n'
            'Recurrence Map: ${metrics.activityRecurrenceDistribution}\n'
            'Type Distribution: ${metrics.healthEventTypeDistribution}\n'
            'Timeline Items Count: ${metrics.activityTimeline.length}';
      });
    } catch (e) {
      setState(() => _output = 'GET PET ANALYTICS ERROR: $e');
    }
  }

  Future<void> _testGetUserAnalytics() async {
    if (_userId == null) {
      setState(
        () => _output = 'ERROR: Sign in first to get an authorized user UUID',
      );
      return;
    }
    try {
      final UserDashboardAnalyticsResponse metrics = await _analytics
          .getUserAnalytics(_userId!);

      setState(() {
        _output =
            'GET USER GLOBAL ANALYTICS SUCCESS:\n'
            'Total Active Pets: ${metrics.totalPets}\n'
            'Combined Scheduled Activities: ${metrics.totalScheduledActivities}\n'
            'Combined Active Routines: ${metrics.totalActiveRoutines}\n'
            'Combined Health Events (This Month): ${metrics.totalHealthEvents}\n'
            'Overall Compliance Rate: ${metrics.medicalComplianceRate}%\n'
            'Global Recurrence Distribution: ${metrics.activityRecurrenceDistribution}\n'
            'Global Health Event Split: ${metrics.healthEventTypeDistribution}\n'
            'Global Timeline Data points: ${metrics.activityTimeline.length}';
      });
    } catch (e) {
      setState(() => _output = 'GET USER GLOBAL ANALYTICS ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Test Screen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('-- AUTH --', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testSignIn,
              child: const Text('Test Sign In'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testGoogleSignIn,
              child: const Text('Test Google Sign In'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testSignUp,
              child: const Text('Test Sign Up'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testChangePassword,
              child: const Text('Test Change Password'),
            ),
            const SizedBox(height: 16),

            const Text('-- PETS --', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testGetPets,
              child: const Text('Test Get Pets By User'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testGetPet2,
              child: const Text('Test Get Pet By ID'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testUpdatePet,
              child: const Text('Test Update Pet'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testDeletePet,
              child: const Text('Test Delete Pet'),
            ),
            const SizedBox(height: 16),

            const Text('-- USER --', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testGetUser,
              child: const Text('Test Get User'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testUpdateUser,
              child: const Text('Test Update User'),
            ),
            const SizedBox(height: 16),

            const Text('-- ACTIVITIES --', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testCreateActivity,
              child: const Text('Test Create Activity'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testGetActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
              ),
              child: const Text('Test Get Activity By ID'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testUpdateActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade50,
              ),
              child: const Text('Test Update Activity'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testDeleteActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
              ),
              child: const Text('Test Delete Activity'),
            ),
            const SizedBox(height: 16),

            const Text('-- HEALTH EVENTS --', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testCreateHealthEvent,
              child: const Text('Test Create Health Event'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testGetHealthEventById,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
              ),
              child: const Text('Test Get Health Event By ID'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testGetHealthEventsByPet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade50,
              ),
              child: const Text('Test Get Health Events By Pet ID'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testCompleteHealthEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade50,
              ),
              child: const Text('Test Mark Health Event Complete'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testDeleteHealthEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
              ),
              child: const Text('Test Delete Health Event'),
            ),
            const SizedBox(height: 16),

            const Text('-- SYSTEM ANALYTICS --', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testGetPetAnalytics,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade50,
                foregroundColor: Colors.teal.shade900,
              ),
              child: const Text('Test Fetch Single Pet Metrics'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testGetUserAnalytics,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade50,
                foregroundColor: Colors.indigo.shade900,
              ),
              child: const Text('Test Fetch User Global Overview'),
            ),
            const SizedBox(height: 20),

            // Main output display block
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_output),
            ),
          ],
        ),
      ),
    );
  }
}
