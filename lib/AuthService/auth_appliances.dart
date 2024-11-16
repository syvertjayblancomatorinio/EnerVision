import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApplianceService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<void> addAppliance(
      String userId, Map<String, dynamic> applianceData) async {
    final url = Uri.parse('$baseUrl/addApplianceNewLogic');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
        'applianceData': applianceData,
      }),
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      print('Appliance added: ${responseBody['appliance']}');
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to add appliance: ${responseBody['error']}');
    } else {
      throw Exception('Unexpected error: ${response.body}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTodayAppliance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }

    final url = Uri.parse('$baseUrl/getAllTodayAppliances/$userId/appliances');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decode the response body as a Map
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Check if 'appliances' key exists and is a list
      if (responseData.containsKey('appliances') &&
          responseData['appliances'] is List) {
        // Return the list of appliances
        return List<Map<String, dynamic>>.from(responseData['appliances']);
      } else {
        throw Exception('Appliances data is not in the expected format');
      }
    } else if (response.statusCode == 404) {
      throw Exception('Appliances not found');
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  // Static method to Read appliances
  static Future<List<Map<String, dynamic>>> fetchAppliance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }

    final url = Uri.parse('$baseUrl/getAllUsersAppliances/$userId/appliances');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Returning the decoded response body
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Appliances not found');
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  static Future<List<dynamic>> fetchAppliances(String userId) async {
    final url = Uri.parse('$baseUrl/user/$userId/appliances');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  // Static method to Update an appliance

  static Future<void> updateAppliance(
      String applianceId, Map<String, dynamic> updatedData) async {
    // Prepare the updated data to include required fields
    final updates = {
      'updatedAt':
          DateTime.now().toIso8601String(), // Current date in ISO format
      'updatedData': updatedData, // Pass the updated data
    };

    final url = Uri.parse('$baseUrl/updateApplianceOccurrences/$applianceId');

    final response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody; // Return response if needed
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to update appliance: ${responseBody['error']}');
    }
  }

  // Static method to delete an appliance
  static Future<void> deleteAppliance(String applianceId) async {
    final url = Uri.parse('$baseUrl/deleteAppliance/$applianceId');
    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to delete appliance: ${responseBody['message']}');
    }
  }

  // Static method to add to monthly consumption

  Future<Map<String, String>?> getDaily() async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString('userId');

    if (userId == null) {
      return null;
    }

    final url = Uri.parse('$baseUrl/totalDailyData/$userId');

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Safely parse the totalDailyConsumptionCost and totalDailyKwhConsumption
        final totalDailyConsumptionCost =
            double.tryParse(data['totalDailyConsumptionCost'].toString()) ??
                0.00;
        final totalDailyKwhConsumption =
            double.tryParse(data['totalDailyKwhConsumption'].toString()) ??
                0.00;

        return {
          'totalDailyConsumptionCost':
              totalDailyConsumptionCost.toStringAsFixed(2),
          'totalDailyKwhConsumption':
              totalDailyKwhConsumption.toStringAsFixed(2),
        };
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }

  static Future<void> deletePost(String postId) async {
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

  static Future<void> addSuggestionToAPost(
      String postId, Map<String, dynamic> suggestionData) async {
    final url = Uri.parse('$baseUrl/addSuggestions/$postId');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
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
/*

Widget _buildUserPost(String title, String description, String timeAgo,
      String tags, String profileImageUrl, String postImageUrl) {
    const String placeholderImage = 'assets/image (6).png';

    final String validProfileImageUrl =
        (profileImageUrl.isNotEmpty) ? profileImageUrl : placeholderImage;

    final String validPostImageUrl =
        (postImageUrl.isNotEmpty) ? postImageUrl : placeholderImage;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: greyBoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: NetworkImage(validProfileImageUrl),
                  child: ClipOval(
                    child: Image.network(
                      validProfileImageUrl,
                      width: 40.0,
                      height: 40.0,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        return Image.asset(
                          placeholderImage,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      tags,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 10.0),
                const Icon(Icons.more_vert),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                validPostImageUrl,
                width: double.infinity,
                height: 200.0,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Image.asset(
                    placeholderImage,
                    width: double.infinity,
                    height: 200.0,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

 */
