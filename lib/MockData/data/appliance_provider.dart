import 'package:flutter/material.dart';

class Appliance {
  String imagePath;
  String name;
  double wattage;
  int usagePattern;

  Appliance({
    required this.imagePath,
    required this.name,
    required this.wattage,
    required this.usagePattern,
  });
}

class ApplianceProvider with ChangeNotifier {
  List<Appliance> _appliances = [];

  List<Appliance> get appliances => _appliances;

  void addAppliance(Appliance appliance) {
    _appliances.add(appliance);
    notifyListeners();
  }

  void editAppliance(int index, Appliance updatedAppliance) {
    _appliances[index] = updatedAppliance;
    notifyListeners();
  }
}
