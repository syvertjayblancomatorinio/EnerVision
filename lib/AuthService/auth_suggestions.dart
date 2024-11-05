import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SuggestionService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<void> addSuggestion(
      String userId, String postId, Map<String, dynamic> suggestionData) async {
    final url = Uri.parse(
        '$baseUrl/addSuggestions/$postId'); // Updated to include postId

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
        'suggestionData': suggestionData, // Changed to suggestionData
      }),
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      print('Suggestion added: ${responseBody['newSuggestion']}');
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to add suggestion: ${responseBody['message']}');
    } else if (response.statusCode == 404) {
      throw Exception('Post not found: ${response.body}');
    } else {
      throw Exception('Unexpected error: ${response.body}');
    }
  }
}
