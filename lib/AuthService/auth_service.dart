import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/segmentPages/appliance_container.dart';
import 'package:supabase_project/login/login_page.dart';

class AuthService {
  final BuildContext context;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? usernameController;
  final TextEditingController? kwhRateController;

  AuthService({
    required this.context,
    required this.emailController,
    required this.passwordController,
    this.usernameController,
    this.kwhRateController,
  });

  Future<void> signUp() async {
    final url = Uri.parse("http://10.0.2.2:8080/signup");

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': emailController.text,
          'password': passwordController.text,
          'username': usernameController?.text ?? '',
          'kwhRate': kwhRateController?.text ?? '',
        }),
      );

      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Email is not available';
        print('User ID not found in response: $errorMessage');
      } else {
        print('Failed to Sign in: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while signing up: $e');
    }
  }

  Future<void> signIn() async {
    final url = Uri.parse("http://10.0.2.2:8080/signin");

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);

        if (responseBody != null &&
            responseBody['user'] != null &&
            responseBody['user']['_id'] != null) {
          String userId = responseBody['user']['_id'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppliancesPage1(userId: userId),
            ),
          );
        } else {
          print('User ID not found in response: ${response.body}');
          // _showSnackBar('User ID not found in response');
        }
      } else {
        print('Failed to Sign in: ${response.body}');
        // _showSnackBar('Failed to Sign in: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while signing up: $e');
      // _showSnackBar('Error occurred while signing in');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
