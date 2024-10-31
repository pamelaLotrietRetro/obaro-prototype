import 'package:flutter/material.dart';
import 'package:test_application/screens/landing.dart';
import 'package:test_application/screens/login.dart';
import 'package:test_application/services/authentication.service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth Demo',
      home: FutureBuilder<String?>(
        future: _checkTokenValidity(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return const LandingScreen(); // Token exists, navigate to home
          } else {
            return const LoginScreen(); // No token or token expired, navigate to login
          }
        },
      ),
    );
  }

  Future<String?> _checkTokenValidity() async {
    final token = await AuthService().getToken();

    if (token != null) {
      return token;
    }

    return null;
  }
}
