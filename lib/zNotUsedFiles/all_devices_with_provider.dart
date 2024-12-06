import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../all_imports/imports.dart';

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
  bool isLoading = false;
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
    getKwhRate();
  }

  @override
  Widget build(BuildContext context) {
    final applianceProvider = Provider.of<ApplianceProvider>(context);

    return MaterialApp(
      theme: ThemeData.dark(),
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
            myAppliancesContent(applianceProvider),
            Positioned (
              bottom: 20.0,
              right: 20.0,

              child: ElevatedButton(
                onPressed: () async {
                  final kwhRate = await getKwhRate();
                  if (kwhRate != null)  {
                    _showAddApplianceDialog(context, applianceProvider);
                  } else {
                    showKwhRateDialog(
                      context: context,
                      kwhRateController: controllers.kwhRateController,
                      saveKwhRate: saveKwhRate,
                      fetchAppliances: applianceProvider.loadAppliances,
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

    String? token = await getToken();
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appliance added successfully!')),
        );
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
        title: 'Network Error',
        message: 'Oops! Something went wrong. Please try again later.',
      );
    }
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

  void _showAddApplianceDialog(
      BuildContext context, ApplianceProvider applianceProvider) {
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
          },
        );
      },
    );
  }
}
