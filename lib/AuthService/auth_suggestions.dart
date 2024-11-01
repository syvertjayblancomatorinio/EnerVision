import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SuggestionService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<List<Map<String, dynamic>>> getComments() async {
    final prefs = await SharedPreferences.getInstance();
    final postId = prefs.getString('postId');

    if (postId == null) {
      throw Exception('Post not found');
    }

    final url =
        Uri.parse('$baseUrl/getAllPostsSuggestions/$postId/suggestions');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Suggestions not found');
    } else {
      throw Exception('Failed to load suggestions: ${response.reasonPhrase}');
    }
  }
}
