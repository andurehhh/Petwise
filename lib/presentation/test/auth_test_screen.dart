import 'package:flutter/material.dart';
import 'package:petwise/contracts/auth/signin_request.dart';
import 'package:petwise/contracts/auth/signup_request.dart';
import 'package:petwise/contracts/pet/update_pet_request.dart';
import 'package:petwise/contracts/user/update_user_request.dart';
import 'package:petwise/services/api_client.dart';
import 'package:petwise/services/auth_service.dart';
import 'package:petwise/services/pet_service.dart';
import 'package:petwise/services/user_service.dart';

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

  //SIGNIN

  Future<void> _testSignIn() async {
    try {
      final result = await _auth.signIn(
        SignInRequest(email: 'renzosua111@gmail.com', password: 'renzo123'),
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

  //SINGUP
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

  //GET PET BY USER ID
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

  //GET PET BY PET ID
  Future<void> _testGetPet2() async {
    try {
      final result = await _pet.getPet(4);
      setState(() => _output = 'GET PET SUCCESS:\n${result.toJson()}');
    } catch (e) {
      setState(() => _output = 'GET PET ERROR: $e');
    }
  }

  //UPDATE PET
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

  //USER INFO USING USER ID
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

  //UPDATE USER INFOs
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
              onPressed: _testSignUp,
              child: const Text('Test Sign Up'),
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
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
