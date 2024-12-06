import 'package:flutter/material.dart';

import '../../AuthService/auth_appliances.dart';

class ApplianceProvider with ChangeNotifier {
  List<Map<String, dynamic>> _appliances = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get appliances => _appliances;
  bool get isLoading => _isLoading;

  Future<void> loadAppliances() async {
    _isLoading = true;
    notifyListeners();

    try {
      _appliances = await ApplianceService.fetchAppliance();
    } catch (e) {
      print('Error loading appliances: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


}
