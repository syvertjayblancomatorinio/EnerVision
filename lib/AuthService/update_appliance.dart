import 'dart:convert';
import 'package:http/http.dart' as http;

class ApplianceService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  // Static method to update an appliance
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

  static Future<void> updateAppliancesdfs(
      String applianceId, Map<String, dynamic> updates) async {
    final url = Uri.parse('$baseUrl/updateAppliance/$applianceId');

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
      throw Exception('Failed to update appliance: ${responseBody['message']}');
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

  // Static method to add an appliance
  static Future<void> addAppliance(
      String userId, Map<String, dynamic> applianceData) async {
    final url = Uri.parse('$baseUrl/addApplianceToUser');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
          <String, dynamic>{'userId': userId, 'applianceData': applianceData}),
    );

    if (response.statusCode == 201) {
      print('Appliance added successfully');
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to add appliance: ${responseBody['message']}');
    }
  }

  // Static method to add to monthly consumption
  static Future<void> addToMonthlyConsumption(
      String userId, String applianceId, String usage) async {
    final url = Uri.parse('$baseUrl/save-consumption');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'applianceId': applianceId,
        'usage': usage,
      }),
    );

    if (response.statusCode == 201) {
      print('Monthly consumption added successfully');
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception(
          'Failed to add monthly consumption: ${responseBody['message']}');
    }
  }

  // Static method to fetch appliances
  static Future<List<dynamic>> fetchAppliances(String userId) async {
    final url = Uri.parse('$baseUrl/user/$userId/appliances');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load appliances');
    }
  }
}
