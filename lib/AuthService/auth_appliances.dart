import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApplianceService {
  static const String baseUrl = 'http://10.0.2.2:8080';

// Static method to Create an appliance
//   Status: unfinished
  static Future<void> addAppliance(
      String userId, Map<String, dynamic> applianceData) async {
    final url = Uri.parse('$baseUrl/addApplianceToUser');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'applianceData': applianceData,
      }),
    );

    // Handling the response
    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      return responseBody['applianceId'];
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to add appliance: ${responseBody['message']}');
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to add appliance: ${responseBody['message']}');
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
  static Future<Map<String, dynamic>> updateAppliance(
      String applianceId, Map<String, dynamic> updates) async {
    final url = Uri.parse('$baseUrl/updateAppliance/$applianceId');

    try {
      final response = await http.patch(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return responseBody; // Return the updated appliance data or confirmation
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(
            'Failed to update appliance: ${responseBody['message']}');
      }
    } catch (e) {
      throw Exception('Error occurred during update: $e');
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
      print('Appliance deleted successfully');
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
      print("User ID is null. Cannot fetch daily consumption.");
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
        return {
          'totalDailyConsumptionCost':
              (data['totalDailyConsumptionCost'] as double).toStringAsFixed(2),
          'totalDailyKwhConsumption':
              (data['totalDailyKwhConsumption'] as double).toStringAsFixed(2),
        };
      } else {
        print('Failed to fetch daily consumption: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('Error fetching daily consumption: $error');
      return null;
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
