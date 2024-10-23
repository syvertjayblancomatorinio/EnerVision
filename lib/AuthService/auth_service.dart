import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/AuthService/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/loading_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';
import 'package:flutter/foundation.dart';

import '../SignUpLogin&LandingPage/setup_profile.dart';

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
  Future<String?> fetchUserProfilePhoto(String userId) async {
    final response = await http.get(
      Uri.parse('http://yourapi.com/getUserProfile?userId=$userId'),
    );

    if (response.statusCode == 200) {
      // Parse the JSON and extract the photo URL
      final profileData = jsonDecode(response.body);
      return profileData[
          'photoUrl']; // Change this based on your API's response structure
    } else if (response.statusCode == 404) {
      print('User profile not found');
      return null;
    } else {
      throw Exception('Failed to load user profile photo');
    }
  }

  Future<http.Response?> signUp() async {
    // String apiUrl =
    //     kReleaseMode ? "http://10.0.2.2:8080/" : "http://192.168.1.217:8080/";
    // final url = Uri.parse("${apiUrl}signup");
    // final url = Uri.parse("http://192.168.1.217/signup");

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
        var responseBody = jsonDecode(response.body);

        String userId = responseBody['user']['_id'];

        // Save the user ID to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SetupProfile()),
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

  Future<http.Response?> signIn() async {
    // Define the API URL based on the environment
    // String apiUrl =
    //     kReleaseMode ? "http://10.0.2.2:8080/" : "http://192.168.1.217:8080/";
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

      // Check for successful response
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

          if (hasProfile) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SplashScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SetupProfile()),
            );
          }
        } else {
          throw Exception('User ID not found in response: ${response.body}');
        }
      } else if (response.statusCode == 401) {
        return response; // Returning the response for error handling
      } else {
        throw Exception('Failed to Sign in: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred while signing in: $e');
    }

    return null;
  }

  Future<void> fetchUserProfile(String userId) async {
    final url = Uri.parse("http://10.0.2.2:8080/getAvatar/$userId");

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var profileData = jsonDecode(response.body);
        String birthDate = profileData['birthDate'];

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
