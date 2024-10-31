import 'package:flutter/material.dart';
import 'package:test_application/screens/login.dart';
import 'package:test_application/services/authentication.service.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => __LandingScreenStateState();
}

class __LandingScreenStateState extends State<LandingScreen> {
  Future<void> _checkTokenValidity() async {
    final token = await AuthService().getToken();
    final expirationTime = await AuthService().getExpirationTime();

    if (token != null && expirationTime != null) {
      if (DateTime.now().isBefore(expirationTime)) {
        print('Token is valid.');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token is valid...')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Token has expired, logging you out../')),
        );
        await AuthService().logout(); // Token is expired, logout
        _navigateToLogin(); // Navigate to LoginScreen
      }
    } else {
      _navigateToLogin(); // No token, navigate to LoginScreen
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _randomAction() async {
    print('testing token logout functionanlity');
    await _checkTokenValidity();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landing Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _randomAction,
          child: const Text('Test'),
        ),
      ),
    );
  }
}
