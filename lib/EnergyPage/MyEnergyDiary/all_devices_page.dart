import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/total_cost&kwh.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/CommonWidgets/dialogs/add_appliance_dialog.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/CommonWidgets/dialogs/micaella.dart';
import 'package:supabase_project/EnergyPage/YourEnergyCalculator&Compare/compare_device.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ConstantTexts/Theme.dart';

class AllDevicesPage extends StatefulWidget {
  final String userId;
  const AllDevicesPage({super.key, required this.userId});

  @override
  _AllDevicesPageState createState() => _AllDevicesPageState();
}

class _AllDevicesPageState extends State<AllDevicesPage> {
  final addApplianceNameController = TextEditingController();
  final addWattageController = TextEditingController();
  final addUsagePatternController = TextEditingController();
  final addWeeklyPatternController = TextEditingController();
  late final TextEditingController controller;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<dynamic> appliances = [];
  Map<String, dynamic> dailyCost = {};

  bool isLoading = false;
  late String? userId;
  late String? selectedDeviceId;

  @override
  void initState() {
    super.initState();
    fetchAppliances();
    getDaily();

    addUsagePatternController.addListener(() {
      String text = addUsagePatternController.text;
      double? value = double.tryParse(text);
      if (value != null && value > 24) {
        addUsagePatternController.value = TextEditingValue(
          text: '24',
          selection: TextSelection.fromPosition(
            const TextPosition(offset: '24'.length),
          ),
        );
      }
    });
  }

  Future<void> _showApplianceErrorDialog(BuildContext context) async {
    ErrorDialogButton errorDialog = const ErrorDialogButton(
      title: 'Appliance not Added',
      message:
          'Invalid Appliance\nOops! The appliance either already exists in your list or the name contains only spaces. Please add a different appliance with a valid name.',
    );

    // Call the showErrorDialog function directly
    errorDialog.showErrorDialog(context);
  }

  Future<void> fetchAppliances() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is null. Cannot fetch appliances.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
        "http://10.0.2.2:8080/getAllUsersAppliances/$userId/appliances");

    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      setState(() {
        appliances = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        isLoading = false;
      });
    } else {
      print('Failed to fetch appliances: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addAppliance() async {
    final url = Uri.parse("http://10.0.2.2:8080/addApplianceToUser");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': widget.userId, // Include userId in the request
        'applianceData': {
          'applianceName': addApplianceNameController.text.trim(),
          'wattage': addWattageController.text,
          'usagePatternPerDay': addUsagePatternController.text,
          'usagePatternPerWeek': addWeeklyPatternController.text
        }
      }),
    );
    if (response != null) {
      if (response.statusCode == 400) {
        // ErrorDialogButton();
        await _showApplianceErrorDialog(context);
      } else if (response.statusCode == 201) {
        print('Appliance added successfully');
        fetchAppliances();
        getDaily();
      } else {
        print('Failed to add appliance: ${response.body}');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(child: Text(message)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> updateAppliance(
      String applianceId, Map<String, dynamic> updates) async {
    final url = Uri.parse('http://10.0.2.2:8080/updateAppliance/$applianceId');

    final response = await http.patch(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      _showSnackBar('Update Success');
    } else {
      // Handle error response
      final responseBody = jsonDecode(response.body);
      _showSnackBar('Failed to update appliance: ${responseBody['message']}');
    }
  }

  Future<void> deleteAppliance(String applianceId) async {
    final url = Uri.parse('http://10.0.2.2:8080/deleteAppliance/$applianceId');
    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      print('Appliance deleted successfully');
      getDaily();
      fetchAppliances();
    } else {
      print('Failed to delete appliance: ${response.body}');
    }
  }

  void showAddApplianceDialog(
      BuildContext context,
      TextEditingController addApplianceNameController,
      TextEditingController addWattageController,
      TextEditingController addUsagePatternController,
      GlobalKey<FormState> formKey,
      VoidCallback addAppliance) {
    addApplianceNameController.clear();
    addWattageController.clear();
    addUsagePatternController.clear();
    addWeeklyPatternController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddApplianceDialog(
          addApplianceNameController: addApplianceNameController,
          addWattageController: addWattageController,
          addUsagePatternController: addUsagePatternController,
          addmonthlyPatternController: addWeeklyPatternController,
          formKey: formKey,
          addAppliance: addAppliance,
        );
      },
    );
  }

  Future<void> getDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is null. Cannot fetch daily consumption.");
      return;
    }

    final url = Uri.parse("http://10.0.2.2:8080/totalDailyData/$userId");

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          dailyCost = {
            'totalDailyConsumptionCost':
                (data['totalDailyConsumptionCost'] as double)
                    .toStringAsFixed(2), // Format to 2 decimal places
            'totalDailyKwhConsumption':
                (data['totalDailyKwhConsumption'] as double)
                    .toStringAsFixed(2), // Format to 2 decimal places
          };
        });

        print(
            'Fetched totalDailyConsumptionCost: ${dailyCost['totalDailyConsumptionCost']}');
        print(
            'Fetched totalDailyKwhConsumption: ${dailyCost['totalDailyKwhConsumption']}');
      } else {
        print('Failed to fetch daily consumption: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching daily consumption: $error');
    }
  }

  @override
  void dispose() {
    addUsagePatternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
        appBar: customAppBar1(
          title: 'All Devices',
          showBackArrow: true,
          showProfile: true,
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: Stack(
          children: [
            myAppliancesContent(),
            Positioned(
              bottom: 20.0,
              right: 20.0,
              child: ElevatedButton(
                onPressed: () => showAddApplianceDialog(
                  context,
                  addApplianceNameController,
                  addWattageController,
                  addUsagePatternController,
                  formKey,
                  addAppliance,
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(24),
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget myAppliancesContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (appliances.isEmpty) {
      return const Center(
        child: Text(
          'No appliances added',
        ),
      );
    } else {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TotalCostDisplay(
                  cost: dailyCost['totalDailyConsumptionCost'] != null
                      ? '₱ ${double.parse(dailyCost['totalDailyConsumptionCost'].toString()).toStringAsFixed(2)}'
                      : 'N/A',
                ),
                const SizedBox(width: 20),
                TotalCostDisplay(
                  cost: dailyCost['totalDailyKwhConsumption'] != null
                      ? '${double.parse(dailyCost['totalDailyKwhConsumption'].toString()).toStringAsFixed(2)} kwh'
                      : 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 50),
            Expanded(
              child: ListView(
                children: appliances.asMap().entries.map((entry) {
                  var appliance = entry.value;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 40),
                        decoration: greyBoxDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 130),
                              child: Text(
                                '${appliance['applianceName'] ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.battery_charging_full),
                                    const SizedBox(width: 5),
                                    Text('${appliance['wattage'] ?? 'N/A'} W'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.watch_later_outlined),
                                    const SizedBox(width: 5),
                                    Text(
                                        '${appliance['usagePatternPerDay'] ?? 'N/A'} hours'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month_outlined),
                                    const SizedBox(width: 5),
                                    Text(
                                      appliance['createdAt'] != null
                                          ? DateFormat('MM/dd').format(
                                              DateTime.parse(
                                                  appliance['createdAt']))
                                          : 'null',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // const SizedBox(height: 40),
                          ],
                        ),
                      ),
                      // Appliance Image (overlapping the container)
                      Positioned(
                        top: -5,
                        left: 20,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            appliance['imagePath'] ?? 'assets/deviceImage.png',
                            width: 102,
                            height: 86,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Compare Button (overlapping at the bottom-right)
                      Positioned(
                        bottom: -10,
                        right: 30,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CompareDevice(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Compare'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }
  }
}
