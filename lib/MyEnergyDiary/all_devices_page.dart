import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:supabase_project/AuthService/auth_appliances.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/total_cost&kwh.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/CommonWidgets/dialogs/micaella.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/CommonWidgets/dialogs/new_add_appliance_dialog.dart';
import '../../ConstantTexts/Theme.dart';
import '../../YourEnergyCalculator&Compare/compare_device.dart';

class AllDevicesPage extends StatefulWidget {
  final String userId;
  const AllDevicesPage({super.key, required this.userId});

  @override
  _AllDevicesPageState createState() => _AllDevicesPageState();
}

class _AllDevicesPageState extends State<AllDevicesPage> {
  final AppControllers controllers = AppControllers();

  late final TextEditingController controller;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List<dynamic> appliances = [];
  Map<String, dynamic> dailyCost = {};
  List<int> selectedDays = [];

  bool isLoading = false;
  late String? userId;
  late String? selectedDeviceId;

  @override
  void initState() {
    super.initState();
    fetchAppliances();
    fetchDailyCost();
  }

  Future<void> _showApplianceErrorDialog(BuildContext context) async {
    ErrorDialogButton errorDialog = const ErrorDialogButton(
      title: 'Appliance not Added',
      message:
          'Invalid Appliance\nOops! The appliance either already exists in your list or the name contains only spaces. Please add a different appliance with a valid name.',
    );
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
    final url = Uri.parse("http://10.0.2.2:8080/addApplianceNewLogic");
    final Map<String, dynamic> applianceData = {
      'applianceName': controllers.addApplianceNameController.text.trim(),
      'wattage': int.tryParse(controllers.addWattageController.text) ?? 0,
      'usagePatternPerDay':
          double.tryParse(controllers.addUsagePatternController.text) ?? 0.0,
      'applianceCategory':
          controllers.addApplianceCategoryController.text.trim(),
      'selectedDays': selectedDays,
    };

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
      fetchAppliances();
    } else {
      await _showApplianceErrorDialog(context);
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

  void _showAddApplianceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddApplianceDialog(
          addApplianceNameController: controllers.addApplianceNameController,
          addWattageController: controllers.addWattageController,
          addUsagePatternController: controllers.addUsagePatternController,
          addApplianceCategoryController:
              controllers.addApplianceCategoryController,
          formKey: formKey,
          addAppliance: (List<int> selectedDays) {
            setState(() {
              this.selectedDays = selectedDays;
            });
            addAppliance();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    controllers.addUsagePatternController.dispose();
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
                onPressed: () => _showAddApplianceDialog(
                  context,
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
