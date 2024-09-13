import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppliancesStorage {
  static const String _key = 'appliances';

  Future<void> saveAppliances(List<Map<String, dynamic>> appliances) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(appliances);
    await prefs.setString(_key, jsonString);
  }

  Future<List<Map<String, dynamic>>> loadAppliances() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
}

final List<Map<String, dynamic>> mockAppliances = [];
// final List<Map<String, dynamic>> dummyAppliances = [];
