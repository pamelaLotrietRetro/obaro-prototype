import 'package:flutter/material.dart';
import 'package:test_application/models/authentication.model.dart';
import 'package:test_application/screens/landing.dart';
import 'package:test_application/services/authentication.service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  Future<void> _login() async {
    AuthService authService = AuthService();

    User user = User(email: email, password: password);
    if (_formKey.currentState!.validate()) {
      try {
        String? token = await authService.login(user);
        print('Login successful! Token: $token');

        // Retrieve the token from secure storage later
        String? storedToken = await authService.getToken();
        print('Stored Token: $storedToken');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully Logged in...')),
        );

        //navigate to new page
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LandingScreen()),
          );
        });
      } catch (e) {
        print('Login failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
              child: Column(
            children: [
              const Text("Welcome Back"),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Email', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Password', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Login Button
                    ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
                  ],
                ),
              )
            ],
          ))),
    );
  }
}
