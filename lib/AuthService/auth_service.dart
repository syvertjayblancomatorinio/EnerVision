import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/all_devices_page.dart';
import 'package:supabase_project/EnergyPage/EnergyTracker/energy_tracker.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/EnergyEfficiency/energy_effieciency_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/home_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/setup_profile.dart';

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
  Future<http.Response?> signUp() async {
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
        print('Error: $errorMessage');
      } else {
        print('Failed to Sign in: ${response.body}');
      }

      return response; // Return the response to handle it in the calling function
    } catch (e) {
      print('Error occurred while signing up: $e');
      return null; // Return null in case of an error
    }
  }

  // Future<void> signUp() async {
  //   final url = Uri.parse("http://10.0.2.2:8080/signup");
  //
  //   try {
  //     var response = await http.post(
  //       url,
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(<String, String>{
  //         'email': emailController.text,
  //         'password': passwordController.text,
  //         'username': usernameController?.text ?? '',
  //         'kwhRate': kwhRateController?.text ?? '',
  //       }),
  //     );
  //
  //     if (response.statusCode == 201) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => LoginPage()),
  //       );
  //     } else if (response.statusCode == 400) {
  //       final responseBody = jsonDecode(response.body);
  //       final errorMessage =
  //           responseBody['message'] ?? 'Email is not available';
  //       print('User ID not found in response: $errorMessage');
  //     } else {
  //       print('Failed to Sign in: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error occurred while signing up: $e');
  //   }
  // }

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
          bool hasProfile =
              responseBody['user']['profiles']; // Check if user has a profile

          // Save the user ID to shared preferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);

          // Redirect based on whether the user has a profile or not
          if (hasProfile) {
            // Redirect to the page if the user has a profile
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EnergyEffieciencyPage(
                  selectedIndex: 0,
                ), // Change to your other page
              ),
            );
          } else {
            // Redirect to SetupProfile if no profile exists
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SetupProfile(),
              ),
            );
          }
        } else {
          print('User ID not found in response: ${response.body}');
          // _showSnackBar('User ID not found in response');
        }
      } else {
        print('Failed to Sign in: ${response.body}');
        // _showSnackBar('Failed to Sign in: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while signing in: $e');
      // _showSnackBar('Error occurred while signing in');
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    final url = Uri.parse("http://10.0.2.2:8080/userProfile/$userId");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var profileData = jsonDecode(response.body);
        String birthDate =
            profileData['birthDate']; // Assuming birthDate is returned

        // Calculate age
        DateTime birth = DateTime.parse(birthDate);
        int age = DateTime.now().year - birth.year;
        if (DateTime.now()
            .isBefore(DateTime(birth.year, birth.month, birth.day))) {
          age--;
        }

        print('User age: $age');
      } else {
        print('Failed to fetch user profile: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while fetching user profile: $e');
    }
  }
}
