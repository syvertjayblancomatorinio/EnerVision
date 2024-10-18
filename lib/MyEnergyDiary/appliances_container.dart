import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_appliances.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/dialogs/kwh_rate_dialog.dart';
import 'package:supabase_project/MyEnergyDiary/common-widgets.dart';
import 'package:supabase_project/zNotUsedFiles/buttons_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_project/CommonWidgets/appliance_container/total_cost&kwh.dart';
import 'package:supabase_project/CommonWidgets/dialogs/add_appliance_dialog.dart';
import 'package:supabase_project/CommonWidgets/dialogs/edit_appliance_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/CommonWidgets/dialogs/error_dialog.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

import '../CommonWidgets/controllers/app_controllers.dart';

const Duration kFakeHttpRequestDuration = Duration(seconds: 3);

class AppliancesContainer extends StatefulWidget {
  const AppliancesContainer({super.key});

  @override
  _AppliancesContainerState createState() => _AppliancesContainerState();
}

class _AppliancesContainerState extends State<AppliancesContainer> {
  final AppControllers controllers = AppControllers();

  late final TextEditingController controller;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> appliances = [];
  Map<String, dynamic> dailyCost = {};
  bool isLoading = true;
  String? kwhRate;
  late String index = '0';

  @override
  void initState() {
    super.initState();
    fetchAppliances();
    fetchDailyCost();
    getKwhRate();
  }

  @override
  void dispose() {
    controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        myAppliancesContent(),
      ],
    );
  }

  Widget myAppliancesContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        // Check if the scroll notification is of type ScrollUpdateNotification
        if (notification is ScrollUpdateNotification) {
          // Check if the scroll position is at the top
          if (notification.metrics.pixels == 0) {
            fetchAppliances();
          }
        }
        return true;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TotalCostDisplay(
                cost: dailyCost['totalDailyConsumptionCost'] != null
                    ? '₱ ${double.parse(dailyCost['totalDailyConsumptionCost'].toString()).toStringAsFixed(2)}'
                    : 'COST',
              ),
              const SizedBox(width: 20),
              TotalCostDisplay(
                cost: dailyCost['totalDailyKwhConsumption'] != null
                    ? '${double.parse(dailyCost['totalDailyKwhConsumption'].toString()).toStringAsFixed(2)} kwh'
                    : 'KWH',
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: 20.0,
              top: 30,
            ),
            child: Text('Appliance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (appliances.isEmpty)
            const Center(
              child: Text(
                'No appliances added',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          else
            ...appliances.asMap().entries.map((entry) {
              int index = entry.key;
              var appliance = entry.value;
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Image.asset(
                        appliance['imagePath'] ?? 'assets/deviceImage.png'),
                    title: Text(appliance['applianceName'] ?? 'Unknown'),
                    subtitle: Text(
                        'Wattage: ${appliance['wattage'] ?? 'N/A'}\nUsage Pattern: ${appliance['usagePatternPerDay'] ?? 'N/A'}\nWeekly Usage: ${appliance['usagePatternPerWeek'] ?? 'N/A'}\n'),
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showActionSheet(context, index),
                      child: const Icon(Icons.more_vert),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final kwhRate = await getKwhRate();

                  if (kwhRate != null) {
                    showAddApplianceDialog(
                      context,
                      controllers.addApplianceNameController,
                      controllers.addWattageController,
                      controllers.addUsagePatternController,
                      controllers.addWeeklyPatternController,
                      controllers.addApplianceCategoryController,
                      formKey,
                      addAppliance,
                    );
                  } else {
                    showKwhRateDialog(
                      context,
                      controllers.kwhRateController,
                      saveKwhRate,
                      fetchAppliances,
                      fetchDailyCost,
                    );
                  }
                },
                icon: const Icon(Icons.add, size: 0),
                label: const Text('Add Appliance'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> saveKwhRate(String kwhRate) async {
    // Wait for SharedPreferences to initialize
    final prefs = await SharedPreferences.getInstance();

    // Get userId from SharedPreferences
    final String? userId = prefs.getString('userId');

    // Check if userId is available
    if (userId == null) {
      throw Exception('User ID not found');
    }

    // Build the request URL
    final url = Uri.parse('http://10.0.2.2:8080/updateKwh/$userId');

    // Send the HTTP PATCH request to update the kWh rate
    final response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'kwhRate': kwhRate}),
    );

    // Log the response for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Check if the request was successful
    if (response.statusCode != 200) {
      throw Exception('Failed to save kWh rate');
    }
  }

  Future<int?> getKwhRate() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }

    final url = Uri.parse('http://10.0.2.2:8080/getUserKwhRate/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('KwhRate found: ${data['kwhRate']}');
      return data['kwhRate'];
    } else if (response.statusCode == 404) {
      print('KwhRate not found for user.');
      return null;
    } else {
      throw Exception('Failed to load user kwhRate');
    }
  }

  void _showActionSheet(BuildContext context, int index) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Appliance Actions'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              openEditApplianceDialog(index);
            },
            child: const Text('Edit Appliance'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAppliance(index);
            },
            child: const Text('Delete Appliance'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context); // Close the action sheet
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _confirmDeleteAppliance(int index) {
    final appliance = appliances[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning, // You can change the icon to any suitable one.
                  color: AppColors.primaryColor,
                  size: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Appliance?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Are you sure you want to delete this appliance? This cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        deleteAppliance(appliance['_id']).then((_) {
                          fetchAppliances();
                          fetchDailyCost();
                          Navigator.of(context).pop();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deleteAppliance(String applianceId) async {
    try {
      await ApplianceService.deleteAppliance(applianceId);
      print('Appliance deleted successfully');
    } catch (e) {
      print('Error deleting appliance: $e');
    }
  }

  Future<void> fetchAppliances() async {
    setState(() {
      isLoading = true;
    });

    try {
      final appliancesData = await ApplianceService.fetchAppliance();
      setState(() {
        appliances = appliancesData;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveAppliance() async {
    final url = Uri.parse("http://10.0.2.2:8080/addApplianceNewLogic");

    // Example selectedDays data (adjust as needed based on user input)
    List<int> selectedDays = [1, 3, 5]; // Sample for Mon, Wed, Fri

    final Map<String, dynamic> applianceData = {
      'applianceName': controllers.addApplianceNameController.text.trim(),
      'wattage': int.tryParse(controllers.addWattageController.text) ?? 0,
      'usagePatternPerDay':
          double.tryParse(controllers.addUsagePatternController.text) ?? 0.0,
      'applianceCategory':
          controllers.addApplianceCategoryController.text.trim(),
      'createdAt':
          DateTime.now().toIso8601String(), // Or allow user input for the date
      'selectedDays':
          selectedDays, // Assuming user-selected days are passed here
    };

    // Assuming you have the `userId` stored in shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId == null) {
      print('User ID not found in shared preferences');
      return;
    }

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'userId': userId,
        'applianceData': applianceData,
      }),
    );

    if (response.statusCode == 201) {
      print('Appliance successfully added');
    } else {
      print('Failed to add appliance: ${response.body}');
    }

    Navigator.of(context).pop(); // Close the dialog
  }

  Future<void> save() async {
    final url = Uri.parse("http://10.0.2.2:8080/addApplianceToUser");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'applianceName': controllers.addApplianceNameController.text,
        'wattage': controllers.addWattageController.text,
        'usagePatternPerDay': controllers.addUsagePatternController.text,
        'applianceCategory': controllers.addApplianceCategoryController.text,
      }),
    );

    print(response.body);
    Navigator.of(context).pop();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showAddApplianceDialog(
      BuildContext context,
      TextEditingController addApplianceNameController,
      TextEditingController addWattageController,
      TextEditingController addUsagePatternController,
      TextEditingController weeklyUsagePatternController,
      TextEditingController addApplianceCategoryController,
      GlobalKey<FormState> formKey,
      VoidCallback addAppliance) {
    addApplianceNameController.clear();
    addWattageController.clear();
    addUsagePatternController.clear();
    weeklyUsagePatternController.clear();
    addApplianceCategoryController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddApplianceDialog(
          addApplianceNameController: addApplianceNameController,
          addWattageController: addWattageController,
          addUsagePatternController: addUsagePatternController,
          formKey: formKey,
          addAppliance: addAppliance,
          addWeeklyPatternController: weeklyUsagePatternController,
          addApplianceCategoryController: addApplianceCategoryController,
        );
      },
    );
  }

  Future<void> _showApplianceErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'Appliance not Added',
      message:
          'Appliance name must not have a duplicate.\nPlease use a different name.',
      buttonText: 'OK',
    );
  }

  Future<void> addToMonthlyConsumption() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final url = Uri.parse("http://10.0.2.2:8080/save-consumption");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'applianceId': controller.text,
        'usage': controller.text,
      }),
    );

    if (response.statusCode == 201) {
      print('Monthly consumption added successfully');
      // Fetch updated appliances after adding a new consumption
      fetchAppliances();
    } else {
      print('Failed to add monthly consumption: ${response.body}');
    }
  }

  Future<void> addAppliance1(
      String userId, Map<String, dynamic> applianceData) async {
    try {
      await ApplianceService.addAppliance(userId, applianceData);
      _showSnackBar('Appliance added successfully');
      fetchDailyCost();
      fetchAppliances();
    } catch (e) {
      print('Failed to add appliance: $e');
    }
  }

  Future<void> newAddAppliance(
      String userId, Map<String, dynamic> applianceData) async {
    try {
      await ApplianceService.newAddAppliances(userId, applianceData);
      _showSnackBar('Appliance added successfully');
      fetchDailyCost();
      fetchAppliances();
    } catch (e) {
      print('Failed to add appliance: $e');
    }
  }

  Future<void> addAppliance() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final url = Uri.parse("http://10.0.2.2:8080/addApplianceToUser");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId, // Include userId in the request
        'applianceData': {
          'applianceName': controllers.addApplianceNameController.text,
          'wattage': controllers.addWattageController.text,
          'usagePatternPerDay': controllers.addUsagePatternController.text,
          'usagePatternPerWeek': controllers.addWeeklyPatternController.text,
          'applianceCategory': controllers.addApplianceCategoryController.text
        }
      }),
    );
    if (response != null) {
      if (response.statusCode == 400) {
        await _showApplianceErrorDialog(context);
      } else if (response.statusCode == 201) {
        print('Appliance added successfully');
        fetchDailyCost();
        fetchAppliances();
      } else {
        print('Failed to add appliance: ${response.body}');
      }
    }
  }

  void fetchDailyCost() async {
    ApplianceService applianceService = ApplianceService();
    final result = await applianceService.getDaily();

    if (result != null) {
      setState(() {
        dailyCost = result;
      });

      print(
          'Fetched totalDailyConsumptionCost: ${dailyCost?['totalDailyConsumptionCost']}');
      print(
          'Fetched totalDailyKwhConsumption: ${dailyCost?['totalDailyKwhConsumption']}');
    } else {
      print('Failed to fetch daily cost');
    }
  }

  Future<void> deleteAppliances(String applianceId) async {
    try {
      await ApplianceService.deleteAppliance(applianceId);
      print('Appliance deleted successfully');
    } catch (e) {
      print('Error deleting appliance: $e');
    }
  }

  Future<void> updateAppliance(
      String applianceId, Map<String, dynamic> updates) async {
    try {
      final updatedAppliance =
          await ApplianceService.updateAppliance(applianceId, updates);
      _showSnackBar('Update Success');

      print('Appliance updated successfully: $updatedAppliance');
    } catch (e) {
      _showSnackBar('Failed to update appliance');
      print('Error updating appliance: $e');
    }
  }

  void openEditApplianceDialog(int index) {
    var appliance = appliances[index];

    controllers.editApplianceNameController.text =
        appliance['applianceName'] ?? '';
    controllers.editWattageController.text =
        appliance['wattage']?.toString() ?? '';
    controllers.editUsagePatternController.text =
        appliance['usagePatternPerDay']?.toString() ?? '';
    controllers.editWeeklyPatternController.text =
        appliance['usagePatternPerWeek']?.toString() ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditApplianceDialog(
          editApplianceNameController: controllers.editApplianceNameController,
          editWattageController: controllers.editWattageController,
          editUsagePatternController: controllers.editUsagePatternController,
          editWeeklyPatternController: controllers.editWeeklyPatternController,
          formKey: formKey,
          editAppliance: () {},
          appliance: appliance,
          updateAppliance: updateAppliance,
          fetchAppliances: fetchAppliances,
          fetchDailyCosts: fetchDailyCost,
        );
      },
    );
  }
}
