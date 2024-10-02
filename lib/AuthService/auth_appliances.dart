import 'dart:convert';
import 'package:http/http.dart' as http;

class ApplianceService {
  static const String baseUrl = 'http://10.0.2.2:8080';

// Static method to Create an appliance
  static Future<String> addAppliance(
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

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      return responseBody['applianceId'];
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to add appliance: ${responseBody['message']}');
    }
  }

  // Static method to Read appliances
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

  // Static method to add to monthly consumption
  static Future<void> addToMonthlyConsumption(
      String userId, String applianceId, String usage) async {
    final url = Uri.parse('$baseUrl/save-consumption');

    try {
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
    } catch (e) {
      print('Error: $e'); // Handle error appropriately
      throw e; // Re-throw if necessary
    }
  }
}
