import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';

import '../../AuthService/auth_appliances.dart';
import '../../AuthService/base_url.dart';
import '../../AuthService/services/user_data.dart';
import '../../AuthService/services/user_service.dart';
import '../../CommonWidgets/controllers/app_controllers.dart';

class ApplianceProvider with ChangeNotifier {
  List<Map<String, dynamic>> _appliances = [];
  bool _isLoading = false;
  late BuildContext context;
  List<Map<String, dynamic>> get appliances => _appliances;
  bool get isLoading => _isLoading;

  // Load appliances from API
// Load appliances from API
  Future<void> loadAppliances() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch appliances from the API
      final response = await ApplianceService.fetchAppliance();

      // Sort appliances by createdAt in descending order (latest to oldest)
      _appliances = response;
      _appliances.sort((a, b) {
        DateTime timestampA = DateTime.parse(a['createdAt']);
        DateTime timestampB = DateTime.parse(b['createdAt']);
        return timestampB.compareTo(timestampA); // Latest first
      });
    } catch (e) {
      print('Error loading appliances: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> loadAppliancesToday() async {
    _isLoading = true;
    notifyListeners();

    try {

      final response = await ApplianceService.fetchTodayAppliance();
      _appliances =
          List<Map<String, dynamic>>.from(response['appliances'] ?? []);
      response['appliances'].sort((a, b) {
        DateTime timestampA = DateTime.parse(a['createdAt']);
        DateTime timestampB = DateTime.parse(b['createdAt']);
        return timestampB.compareTo(timestampA); // Sort in descending order
      });
      print('Appliances Fetched From Provider');
    } catch (e) {
      print('Error loading appliances: $e');
      showSnackBar(context, 'Failed to load appliances. Please try again.');
      // Optionally, set an error message to be shown in the UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
