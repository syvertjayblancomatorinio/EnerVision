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
  bool isLoading = true;

  @override
  void dispose() {
      controllers.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
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
            if (isLoading)
              const Center(
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
                    return const Center(
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
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final kwhRate = await getKwhRate();
            if (kwhRate != null) {
              _showAddApplianceDialog(context);
            } else {
              showKwhRateDialog(
                context: context,
                kwhRateController: controllers.kwhRateController,
                saveKwhRate: saveKwhRate,
                fetchAppliances: (){},
                fetchDailyCost: () {},
              );
            }
          },
          backgroundColor: AppColors.primaryColor,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ), // Set the background color if needed
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
    );
    errorDialog.showErrorDialog(context);

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

}
