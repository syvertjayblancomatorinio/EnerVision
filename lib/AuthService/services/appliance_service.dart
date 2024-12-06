import 'package:hive/hive.dart';

import '../models/all_devices_model.dart';

class ApplianceService {
  static Future<void> addAppliance(Appliance appliance) async {
    try {
      final box = await Hive.openBox<Appliance>('appliances');
      await box.add(appliance);
    } catch (e) {
      print('Error adding appliance to Hive: $e');
    }
  }

  static Future<List<Appliance>> getAllAppliances() async {
    try {
      final box = await Hive.openBox<Appliance>('appliances');
      return box.values.cast<Appliance>().toList();
    } catch (e) {
      print('Error retrieving appliances from Hive: $e');
      return [];
    }
  }

  static Future<void> updateAppliance(int index, Appliance updatedAppliance) async {
    try {
      final box = await Hive.openBox<Appliance>('appliances');
      await box.putAt(index, updatedAppliance);
    } catch (e) {
      print('Error updating appliance in Hive: $e');
    }
  }

  static Future<void> deleteAppliance(int index) async {
    try {
      final box = await Hive.openBox<Appliance>('appliances');
      await box.deleteAt(index);
    } catch (e) {
      print('Error deleting appliance from Hive: $e');
    }
  }
}
