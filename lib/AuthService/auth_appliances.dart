import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/AuthService/base_url.dart';
import 'package:supabase_project/AuthService/services/user_service.dart';
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';

import 'models/user_model.dart';
import 'services/user_data.dart';



class ApplianceService {
  static Future<void> addAppliance(
      String userId, Map<String, dynamic> applianceData) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/addApplianceNewLogic');
    String? token = await getUserToken();

    if (token == null) {
      // print('Token not found');
      return;
    }

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',

      },
      body: jsonEncode({
        'userId': userId,
        'applianceData': applianceData,
      }),
    );
    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
    } else if (response.statusCode == 400) {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to add appliance: ${responseBody['error']}');
    } else {
      throw Exception('Unexpected error: ${response.body}');
    }
    }

  static Future<Map<String, dynamic>> fetchTodayAppliance() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    if (currentUser == null || currentUser.userId.isEmpty) {
      throw Exception('User data not found in Hive');
    }

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/getAllTodayAppliances/${currentUser.userId}/appliances');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Ensure that 'appliances' is a list, and provide defaults if any values are missing
        return {
          'appliances': List<Map<String, dynamic>>.from(responseData['appliances'] ?? []),
          'totalDailyConsumptionCost': double.tryParse(responseData['totalDailyConsumptionCost']?.toString() ?? '0') ?? 0.0,
          'totalDailyKwhConsumption': double.tryParse(responseData['totalDailyKwhConsumption']?.toString() ?? '0') ?? 0.0,
          'totalDailyCO2Emissions': double.tryParse(responseData['totalDailyCO2Emissions']?.toString() ?? '0') ?? 0.0,
        };
      } else if (response.statusCode == 404) {
        throw Exception('Appliances not found');
      } else {
        throw Exception('Failed to load appliances with status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Re-throw the error so it can be handled elsewhere
    }
  }


  // Static method to Read appliances
  static Future<List<Map<String, dynamic>>> fetchAppliance() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    if (currentUser!.userId.isEmpty) {
      throw Exception('User ID not found in shared preferences');
    }

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/getAllUsersAppliances/${currentUser.userId}/appliances');

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


  static Future<void> updateAppliance(
      String applianceId, Map<String, dynamic> updatedData) async {
    if (updatedData.containsKey('applianceName')) {
      updatedData['applianceName'] = toTitleCase(updatedData['applianceName']);
    }

    // Prepare the updated data to include required fields
    final updates = {
      'updatedAt': DateTime.now().toIso8601String(),
      'updatedData': updatedData,
    };

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/updateApplianceOccurrences/$applianceId');
    String? token = await getUserToken();

    if (token != null) {
      final response = await http.patch(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
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
  }

  // Static method to delete an appliance
  static Future<void> deleteAppliance(String applianceId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/deleteAppliance/$applianceId');
    // String? token = await getToken();.
    String? token = await getUserToken();

    if (token != null) {
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
      } else {
        final responseBody = jsonDecode(response.body);
        throw Exception(
            'Failed to delete appliance: ${responseBody['message']}');
      }
    }
  }

  // Static method to add to monthly consumption

  Future<Map<String, String>?> getDaily() async {
    String? userId = await UserService.getUserId();

    if (userId == null) {
      return null;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/totalDailyData/$userId');

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
    final url = Uri.parse('${ApiConfig.baseUrl}/deletePost/$postId');

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

  static Future<void> addSuggestionToAPost(
      String postId, Map<String, dynamic> suggestionData) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/addSuggestions/$postId');
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
