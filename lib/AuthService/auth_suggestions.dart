import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'base_url.dart';

class SuggestionService {
  static Future<void> addSuggestion(
      String userId, String postId, Map<String, dynamic> suggestionData) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/addSuggestions/$postId');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
        'suggestionData': suggestionData,
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
