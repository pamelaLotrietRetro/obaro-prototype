import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:test_application/models/authentication.model.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:5000';
  final storage = const FlutterSecureStorage();

  Future<String?> login(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()), // Use the toJson method
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      // Decode the token to get the expiration time
      final payload = _decodeJwt(token);
      final exp = payload['exp'];

      // Store the token and its expiration time
      await storage.write(key: 'token', value: token);
      await storage.write(key: 'expiration', value: exp.toString());

      _checkTokenValidity();
      // if (response.statusCode == 401) {
      //   await logout(); // Logout if token is invalid or expired
      // }

      return token;
    } else {
      throw Exception('Failed to login');
    }
  }

  // Decode JWT token to extract payload
  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<DateTime?> getExpirationTime() async {
    final expString = await storage.read(key: 'expiration');
    if (expString != null) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(expString) * 1000);
    }
    return null;
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
    await storage.delete(key: 'expiration');
  }

  Future<String?> _checkTokenValidity() async {
    final token = await AuthService().getToken();
    final expirationTime = await AuthService().getExpirationTime();

    if (token != null && expirationTime != null) {
      // Check if the current time is before the expiration time
      if (DateTime.now().isBefore(expirationTime)) {
        return token; // Token is valid
      } else {
        await AuthService().logout(); // Token is expired, logout
        return null; // Token expired, return null to trigger navigation to LoginScreen
      }
    }

    return null; // No token or token expired
  }
}
