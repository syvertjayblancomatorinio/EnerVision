import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_project/AuthService/auth_appliances.dart';
import 'package:supabase_project/AuthService/base_url.dart';
import 'package:supabase_project/AuthService/services/user_data.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/total_cost&kwh.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';
import 'package:supabase_project/CommonWidgets/dialogs/appliance_information_dialog.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/dialogs/micaella.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/CommonWidgets/dialogs/new_add_appliance_dialog.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/CommonWidgets/dialogs/rate_dialog.dart';
import '../../ConstantTexts/Theme.dart';
import '../../YourEnergyCalculator&Compare/compare_device.dart';
import '../AuthService/kwh_rate.dart';
import '../AuthService/models/user_model.dart';
import '../AuthService/preferences.dart';
import '../AuthService/services/user_service.dart';
import '../PreCode/Provider/ApplianceProvider.dart';

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
  Map<String, dynamic> dailyCost = {};
  List<dynamic> appliances = [];
  List<int> selectedDays = [];
  bool isLoading = true;

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
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
    fetchAppliances();
    getKwhRate();
  }

  @override
  Widget build(BuildContext context) {
    final applianceProvider = Provider.of<ApplianceProvider>(context);

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
            // Display loading for 3 seconds when the page is loaded
            if (isLoading)
              Center(
                child: LoadingWidget(
                  message: 'Fetching all appliances...',
                  color: AppColors.primaryColor,
                ),
              )
            else
            // Once loading is complete, display the appliances
              Consumer<ApplianceProvider>(
                builder: (context, applianceProvider, child) {
                  if (applianceProvider.isLoading) {
                    return Center(
                      child: LoadingWidget(
                        message: 'Fetching all appliances...',
                        color: AppColors.primaryColor,
                      ),
                    );
                  }

                  if (applianceProvider.appliances.isEmpty) {
                    return const Center(child: Text('No appliance added.\nTap "+" to start tracking.'));
                  }

                  return myAppliancesContent(applianceProvider);
                },
              ),

            // Positioned button to add appliance
            Positioned(
              bottom: 20.0,
              right: 20.0,
              child: ElevatedButton(
                onPressed: () async {
                  final kwhRate = await getKwhRate();
                  if (kwhRate != null) {
                    _showAddApplianceDialog(context);
                  } else {
                    showKwhRateDialog(
                      context: context,
                      kwhRateController: controllers.kwhRateController,
                      saveKwhRate: saveKwhRate,
                      fetchAppliances: fetchAppliances,
                      fetchDailyCost: () {},
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


  Widget myAppliancesContent(ApplianceProvider applianceProvider) {
    return ListView.builder(
      itemCount: applianceProvider.appliances.length,
      itemBuilder: (context, index) {
        return applianceItem(
          applianceProvider.appliances[index],
          index,
        );
      },
    );
  }

  Widget myAppliancesContentOld(ApplianceProvider applianceProvider) {
    if (applianceProvider.isLoading) {
      return const Center(
        child: LoadingWidget(
          message: 'Fetching all appliances',
          color: AppColors.primaryColor,
        ),
      );
    } else if (applianceProvider.appliances.isEmpty) {
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
      return ListView.builder(
        itemCount: applianceProvider.appliances.length,
        itemBuilder: (context, index) {
          return applianceItem(
            applianceProvider.appliances[index],
            index,
          );
        },
      );
    }
  }

  // Widget myAppliancesContent() {
  //   if (isLoading) {
  //     return const Center(
  //         child: LoadingWidget(
  //       message: 'Fetching all appliances',
  //       color: AppColors.primaryColor,
  //     ));
  //   } else if (appliances.isEmpty) {
  //     return Center(
  //       child: Text(
  //         'No appliance added.\nTap "+" to start tracking.',
  //         textAlign: TextAlign.center,
  //         style: TextStyle(
  //           fontSize: 16,
  //           color: Colors.grey[700],
  //         ),
  //       ),
  //     );
  //   } else {
  //     return ListView.builder(
  //       itemCount: appliances.length,
  //       itemBuilder: (context, index) {
  //         return applianceItem(appliances[index], index);
  //       },
  //     );
  //   }
  // }

  //Todo: Display the appliances from latest to oldest
  Widget applianceItem(Map<String, dynamic> appliance, int index) {
    return GestureDetector(
      onTap: () {
        showApplianceInformationDialog(index);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
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
              ],
            ),
          ),
          deviceImages(appliance),
        ],
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
          appliance['imagePath'] ?? 'assets/appliance.jpg',
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
    try {
      double? kwhRate = await KWHRateService.getKwhRate();
      if (kwhRate != null) {
        print('Current kWh Rate: $kwhRate');
        return kwhRate;
      } else {
        print('kWh Rate not found');
        return null;
      }
    } catch (e) {
      print('Error fetching kWh rate: $e');
      return 0.00; // Return null in case of error
    }
  }

  Future<void> _showErrorDialog(
      BuildContext context, {
        required String title,
        required String message,
        String buttonText = 'OK', // Default button text
      }) async {
    ErrorDialogButton errorDialog = ErrorDialogButton(
      title: title,
      message: message,
      // buttonText: buttonText, // Allow button text customization
    );
    errorDialog.showErrorDialog(context);
  }

  Future<void> fetchAppliances() async {
    setState(() {
      isLoading = true;
    });

    String? userId = await UserService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID is null. Cannot fetch appliances.')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
        "${ApiConfig.baseUrl}/getAllUsersAppliances/$userId/appliances");
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      setState(() {
        // Parse the response body into a list of appliances
        appliances = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        appliances.sort((a, b) {
          DateTime timestampA = DateTime.parse(a['createdAt']);
          DateTime timestampB = DateTime.parse(b['createdAt']);
          return timestampB.compareTo(timestampA);
        });

        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            Text('Failed to fetch appliances: ${response.statusCode}')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void showApplianceInformationDialog(int index) {
    var appliance = appliances[index];

    controllers.editApplianceNameController.text =
        appliance['applianceName'] ?? '';
    controllers.editWattageController.text =
        appliance['wattage']?.toString() ?? '';
    controllers.editUsagePatternController.text =
        appliance['usagePatternPerDay']?.toString() ?? '';
    controllers.editWeeklyPatternController.text =
        appliance['selectedDays']?.toString() ?? '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ApplianceInformationDialog(
          appliance: appliance,
        );
      },
    );
  }

  Future<void> showKwhRateDialog({
    required BuildContext context,
    required TextEditingController kwhRateController,
    required Function(String kwhRate) saveKwhRate,
    required Function() fetchAppliances,
    required Function() fetchDailyCost,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return KwhRateDialog(
          kwhRateController: kwhRateController,
          saveKwhRate: saveKwhRate,
          fetchAppliances: fetchAppliances,
          fetchDailyCost: fetchDailyCost,
        );
      },
    );
  }

  Future<void> saveKwhRate(String kwhRate) async {
    try {
      await KWHRateService.saveKwhRate(kwhRate);
      print('kWh rate saved successfully');
    } catch (e) {
      print('Error saving kWh rate: $e');
    }
  }

  Future<void> addAppliance() async {
    final url = Uri.parse("${ApiConfig.baseUrl}/addApplianceNewLogic");

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

    String? userId = await UserService.getUserId();
    if (userId == null) {
      print('User ID not found in shared preferences');
      return;
    }

    String? token = await getUserToken();
    if (token == null) {
      print('Token not found');
      return;
    }

    try {
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'applianceData': applianceData,
        }),
      );

      if (response.statusCode == 409) {
        // Conflict: Appliance already exists
        _showErrorDialog(
          context,
          title: 'Appliance not Added',
          message:
          'Invalid Appliance\nOops! The appliance either already exists in your list or the name contains only spaces. Please add a different appliance with a valid name.',
        );
      } else if (response.statusCode == 201) {
        // Success: Appliance added
        showSnackBar(context, 'Appliance Addded');
        fetchAppliances();
      } else {
        // Other errors: Show error dialog with response body for debugging
        _showErrorDialog(
          context,
          title: 'Network Error',
          message: 'Oops! Something went wrong. Please try again later.',
        );
      }
    } catch (e) {
      // Handle exceptions (e.g., network errors)
      print('Error adding appliance: $e');
      _showErrorDialog(
        context,
        title: 'Unknown error',
        message: 'Oops! Something went wrong. Please try again later.',
      );
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
          addAppliance: (List<int> newSelectedDays) {
            setState(() {
              selectedDays = newSelectedDays; // Update selectedDays
            });
            addAppliance();
            // Delay loading appliances for 3 seconds
          },
        );
      },
    );
  }
}
