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
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/dialogs/micaella.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/CommonWidgets/dialogs/new_add_appliance_dialog.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final TextEditingController controller;
  final Map<String, String> _electricProviders = {
    'Cebu Electric Cooperative': '10.5',
    'Visayan Electric Company (VECO) - Residential': '11.2',
    'Visayan Electric Company (VECO) - Commercial': '15.2',
    'Mactan Electric Company - Residential': '10.8',
    'Mactan Electric Company - Commercial': '13.8',
    'Churba': '12.0',
    'Gengeng': '15.5',
    'Juju on the Beat': '18',
    'Eyy': '33',
    'Waw': '21',
  };

  Map<String, dynamic> dailyCost = {};
  List<dynamic> appliances = [];
  List<int> selectedDays = [];

  bool isLoading = false;
  late String? userId;
  late String? selectedDeviceId;
  String? _selectedProvider;

  @override
  void dispose() {
    controllers.addUsagePatternController.dispose();
    controllers.addApplianceCategoryController.dispose();

    controllers.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchAppliances();
    fetchDailyCost();
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
                onPressed: () async {
                  final kwhRate = await getKwhRate();

                  if (kwhRate != null) {
                    _showAddApplianceDialog(
                      context,
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
          child: LoadingWidget(
        message: 'Fetching all appliances',
        color: AppColors.primaryColor,
      ));
    } else if (appliances.isEmpty) {
      return Center(
        child: Text(
          'No appliance added.\nTap "+" to start tracking.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            dailyConsumption(),
            const SizedBox(height: 60),
            appliancesContent(),
          ],
        ),
      );
    }
  }

  Widget appliancesContent() {
    return Expanded(
      child: ListView(
        children: appliances.asMap().entries.map((entry) {
          var appliance = entry.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                padding:
                    const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
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

                    const SizedBox(height: 20),
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
                                      DateTime.parse(appliance['createdAt']))
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
              deviceImages(appliance),
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
    );
  }

  Widget deviceImages(appliance) {
    return Positioned(
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
    );
  }

  Widget dailyConsumption() {
    return Row(
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
    );
  }

  Future<double?> getKwhRate() async {
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
      return (data['kwhRate'] as num)
          .toDouble(); // Ensures it’s returned as a double
    } else if (response.statusCode == 404) {
      print('KwhRate not found for user.');
      return null;
    } else {
      throw Exception('Failed to load user kwhRate');
    }
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
    String applianceName = toTitleCase(
      controllers.addApplianceNameController.text.trim(),
    );

    final Map<String, dynamic> applianceData = {
      'applianceName': applianceName,
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

  Future<void> showKwhRateDialog(
      BuildContext context,
      TextEditingController kwhRateController,
      Function saveKwhRate,
      Function fetchAppliances,
      Function fetchDailyCost) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              // title: const Text('Enter kWh Rate'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Icon and Title
                  const Icon(
                    Icons.electrical_services,
                    size: 50,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Kilowatt-Hour Rate',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Flexible(
                    child: DropdownButtonFormField<String>(
                      value: _selectedProvider,
                      isExpanded: true,
                      hint: const Text('Select your Electric Service Provider'),
                      items: _electricProviders.keys.map((String provider) {
                        return DropdownMenuItem<String>(
                          value: provider,
                          child: Text(
                            provider,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14.0),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedProvider = newValue;
                          controllers.kwhRateController.text =
                              _electricProviders[newValue!]!;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  Flexible(
                    child: TextField(
                      controller: controllers.kwhRateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Kilowatt Hour Rate (kWh)',
                        hintStyle: const TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 25.0),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                                color: Color(0xFFB1B1B1), width: 1),
                          ),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(fontSize: 14.0)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String kwhRate = controllers.kwhRateController.text;

                          try {
                            await saveKwhRate(kwhRate);
                            Navigator.of(context).pop();
                            _showAddApplianceDialog(context);
                            fetchAppliances();
                            fetchDailyCost();
                          } catch (e) {
                            print('Failed to save kWh rate: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: const Color(0xFF1BBC9B),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 14.0, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
    controllers.addApplianceNameController.clear();
    controllers.addWattageController.clear();
    controllers.addUsagePatternController.clear();
    controllers.addApplianceCategoryController.clear();
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
            fetchDailyCost();
          },
        );
      },
    );
  }
}
