import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostsService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // Fetch posts from the API
  static Future<List<Map<String, dynamic>>> getPosts() async {
    final url = Uri.parse('$baseUrl/displayPosts');
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      List<dynamic> fetchedPosts = jsonDecode(response.body)['posts'] ?? [];

      return fetchedPosts.map<Map<String, dynamic>>((post) {
        DateTime createdAt = DateTime.parse(post['createdAt']);
        String timeAgo = _timeAgo(createdAt);
        return {
          'title': post['title'] ?? 'No title',
          'description': post['description'] ?? 'No description',
          'tags': post['tags'] ?? 'No tags',
          'imagePath': 'assets/image (6).png',
          'timeAgo': timeAgo,
          'username': post['userId'] != null
              ? post['userId']['username']
              : 'Unknown user',
        };
      }).toList();
    } else {
      throw Exception('Failed to load Posts');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUsersPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }

    final url = Uri.parse('$baseUrl/getAllPosts/$userId/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Change this line to check if the response is a Map or List
      final data = jsonDecode(response.body);
      // If 'posts' is a key in the response, extract it
      if (data is Map<String, dynamic> && data.containsKey('posts')) {
        return List<Map<String, dynamic>>.from(data['posts']);
      } else {
        return List<Map<String, dynamic>>.from(data);
      }
    } else if (response.statusCode == 404) {
      throw Exception('User\'s post not found');
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  static Future<void> deleteAPost(String postId) async {
    final url = Uri.parse('$baseUrl/deletePost/$postId');
    print('Sending DELETE request to: $url');

    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('Post with ID $postId deleted successfully.');
    } else {
      final responseBody = jsonDecode(response.body);
      print('Failed to delete appliance. Server response: ${response.body}');
      throw Exception('Failed to delete appliance: ${responseBody['message']}');
    }
  }

  static Future<void> deletePost(String postId) async {
    final url = Uri.parse('$baseUrl/posts/$postId');
    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      print('Post deleted successfully');
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to delete Post: ${responseBody['message']}');
    }
  }
  // It's almost 3am and I still couldn't figure out how to add suggestions to the specific post hays kapoy na.

  // Helper method to calculate "time ago"
  static String _timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final url = Uri.parse('$baseUrl/getAllPostsSuggestions/$postId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } catch (e) {
        throw Exception('Failed to parse suggestions data');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Suggestions not found');
    } else {
      throw Exception('Failed to load suggestions: ${response.reasonPhrase}');
    }
  }
}
