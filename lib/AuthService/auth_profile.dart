import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  Future<String?> getAvatar(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);

    final response = await http
        .get(Uri.parse('http://10.0.2.2:8080/getAvatar?userId=$userId'));

    if (response.statusCode == 200) {
      // Parse the JSON and extract the avatar URL
      final profileData = jsonDecode(response.body);
      return profileData['avatar'];
    } else if (response.statusCode == 404) {
      print('User profile not found');
      return null;
    } else {
      throw Exception('Failed to load user profile photo');
    }
  }
}
