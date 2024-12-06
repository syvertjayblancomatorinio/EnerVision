import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../../AuthService/base_url.dart';
import '../../AuthService/models/user_model.dart';

class ApplianceService {
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

        return {
          'appliances': List<Map<String, dynamic>>.from(responseData['appliances'] ?? []),
          'totalDailyConsumptionCost': double.tryParse(
            responseData['totalDailyConsumptionCost']?.toString() ?? '0',
          ) ??
              0.0,
          'totalDailyKwhConsumption': double.tryParse(
            responseData['totalDailyKwhConsumption']?.toString() ?? '0',
          ) ??
              0.0,
          'totalDailyCO2Emissions': double.tryParse(
            responseData['totalDailyCO2Emissions']?.toString() ?? '0',
          ) ??
              0.0,
        };
      } else if (response.statusCode == 404) {
        throw Exception('Appliances not found');
      } else {
        throw Exception('Failed to load appliances with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while fetching appliances: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAppliance() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    if (currentUser == null || currentUser.userId.isEmpty) {
      throw Exception('User ID not found in Hive');
    }

    final url = Uri.parse(
        '${ApiConfig.baseUrl}/getAllUsersAppliances/${currentUser.userId}/appliances');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Appliances not found');
      } else {
        throw Exception('Failed to load appliances');
      }
    } catch (e) {
      print('Error occurred while fetching appliances: $e');
      rethrow;
    }
  }
}
