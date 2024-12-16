
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../all_imports/imports.dart';

class AppliancesContainer extends StatefulWidget {
  const AppliancesContainer({super.key});

  @override
  _AppliancesContainerState createState() => _AppliancesContainerState();
}

class _AppliancesContainerState extends State<AppliancesContainer> {
  final AppControllers controllers = AppControllers();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final formatter = NumberFormat('#,##0.00', 'en_PHP');

  List<Map<String, dynamic>> appliances = [];
  List<int> selectedDays = [];
  Map<String, dynamic> dailyCost = {};

  bool isLoading = true;

  late String index = '0';
  String? kwhRate;
  String? _selectedProvider;

  double totalDailyConsumptionCost = 0.0;
  double totalDailyKwhConsumption = 0.0;
  double totalDailyCO2Emissions = 0.0;

  @override
  void initState() {
    super.initState();
    fetchTodayAppliances();
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
    return Consumer<ApplianceProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            myAppliancesContent(provider),
          ],
        );
      },
    );
  }


  Future<void> _fetchAppliances() async {
    try {
      final appliances = await fetchTodayAppliance();
      // Now you can use the appliances fetched from either Hive or the API
    } catch (e) {
    }
  }

  static Future<Map<String, dynamic>> fetchTodayAppliance() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    if (currentUser == null || currentUser.userId.isEmpty) {
      throw Exception('User data not found in Hive');
    }

    // First, check if appliances are already in Hive
    final applianceBox = await Hive.openBox('appliancesBox');
    if (applianceBox.containsKey('todayAppliances')) {
      // If appliances are in Hive, return them
      final appliances = applianceBox.get('todayAppliances');
      return appliances;
    }

    // If not found in Hive, fetch from API
    final url = Uri.parse('${ApiConfig.baseUrl}/getAllTodayAppliances/${currentUser.userId}/appliances');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final appliances = {
          'appliances': List<Map<String, dynamic>>.from(responseData['appliances'] ?? []),
          'totalDailyConsumptionCost': double.tryParse(responseData['totalDailyConsumptionCost']?.toString() ?? '0') ?? 0.0,
          'totalDailyKwhConsumption': double.tryParse(responseData['totalDailyKwhConsumption']?.toString() ?? '0') ?? 0.0,
          'totalDailyCO2Emissions': double.tryParse(responseData['totalDailyCO2Emissions']?.toString() ?? '0') ?? 0.0,
        };

        // Store fetched appliances in Hive for future use
        await applianceBox.put('todayAppliances', appliances);

        return appliances;
      } else if (response.statusCode == 404) {
        throw Exception('Appliances not found');
      } else {
        throw Exception('Failed to load appliances with status code: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Re-throw the error so it can be handled elsewhere
    }
  }

  Future<void> fetchTodayAppliances() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch the appliance data from the service
      final todayData = await ApplianceService.fetchTodayAppliance();

      // Sort the appliances list by timestamp (latest first)
      todayData['appliances'].sort((a, b) {
        DateTime timestampA = DateTime.parse(a['createdAt']);
        DateTime timestampB = DateTime.parse(b['createdAt']);
        return timestampB.compareTo(timestampA); // Sort in descending order
      });

      setState(() {
        appliances = todayData['appliances']; // Appliances after sorting
        totalDailyConsumptionCost = todayData['totalDailyConsumptionCost'];
        totalDailyKwhConsumption = todayData['totalDailyKwhConsumption'];
        totalDailyCO2Emissions = todayData['totalDailyCO2Emissions'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

    }
  }



  //Todo: Display the appliances from latest to oldest
  Widget myAppliancesContent(ApplianceProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCostDisplay(),
        const Padding(
          padding: EdgeInsets.only(left: 20.0, top: 30),
          child: Text(
            'Appliance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        _buildApplianceList(provider),
        const SizedBox(height: 20),
        _buildAddApplianceButton(),
      ],
    );
  }

  Widget _buildCostDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TotalCostDisplay(
          cost: totalDailyConsumptionCost != null
              ? '₱ ${totalDailyConsumptionCost.toStringAsFixed(2)}'
              : 'Cost',
        ),
        const SizedBox(width: 20),
        TotalCostDisplay(
          cost: totalDailyKwhConsumption != null
              ? '${totalDailyKwhConsumption.toStringAsFixed(2)} KWH'
              : 'KWH',
        ),
      ],
    );
  }

  Widget _buildApplianceList(ApplianceProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: LoadingWidget(
          message: 'Fetching Today\'s Appliances...',
          color: AppColors.primaryColor,
        ),
      );
    } else if (provider.appliances.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 200, bottom: 100),
        child: const Center(
          child: Text(
            'No appliances added for \n Today\'s Appliances...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    } else {
      return Column(
        children: provider.appliances.asMap().entries.map((entry) {
          int index = entry.key;
          var appliance = entry.value;

          return Center(
            child: GestureDetector(
              onTap: () {
                showApplianceInformationDialog( index);
              },
              child: _buildApplianceCard(appliance, index),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildApplianceCard(Map appliance, int index) {
    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: greyBoxDecoration(),
      child: ListTile(
        leading: ClipOval(
          child: Image.asset(
            appliance['imagePath'] ?? 'assets/appliance.jpg',
            height: 50,
            width: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          appliance['applianceName'] ?? 'Unknown Device',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Wattage: ${appliance['wattage'] ?? 'N/A'}'
              '     '
              'Hours Used: ${appliance['usagePatternPerDay'] ?? 'N/A'}\n',
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showActionSheet(context, index),
          child: Image.asset(
            'assets/edit.png',
            scale: 0.7,
          ),
        ),
      ),
    );
  }

  Widget _buildAddApplianceButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            final kwhRate = await getKwhRate();

            if (kwhRate != null) {
              _showAddApplianceDialog(context,);
            } else {
              showKwhRateDialog(
                context: context,
                kwhRateController: controllers.kwhRateController,
                saveKwhRate: saveKwhRate,
                fetchAppliances: fetchTodayAppliances,
                fetchDailyCost: fetchDailyCost,
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
    );
  }


  Widget _popupTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _popupDescription(String description) {
    return Text(
      description,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[500],
        fontFamily: 'Montserrat',
      ),
    );
  }

  Future<double?> getKwhRate() async {
    try {
      double? kwhRate = await KWHRateService.getKwhRate();
      if (kwhRate != null) {
        return kwhRate;
      } else {
        return null;
      }
    } catch (e) {
      return 0.00; // Return null in case of error
    }
  }

  Future<void> deleteAppliance(String applianceId) async {
    try {
      await ApplianceService.deleteAppliance(applianceId);
    } catch (e) {
    }
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



  Future<void> addAppliance1() async {
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

    // Retrieve userId from Hive

    if (userId == null) {
      return;
    }

    // Retrieve token from Hive
    String? token = await getUserToken();
    if (token != null) {
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

      if (response.statusCode == 201) {

        fetchTodayAppliances();
        fetchDailyCost();
      } else {
        await _showApplianceErrorDialog(context);
      }
    } else {
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
      'usagePatternPerDay': double.tryParse(controllers.addUsagePatternController.text) ?? 0.0,
      'applianceCategory': controllers.addApplianceCategoryController.text.trim(),
      'selectedDays': selectedDays,
      'createdAt': DateTime.now().toIso8601String(), // Send local time explicitly
    };

    String? userId = await UserService.getUserId();

    if (userId == null) {
      return;
    }

    String? token = await getUserToken();
    if (token != null) {
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

      if (response.statusCode == 201) {
        fetchTodayAppliances();
        fetchDailyCost();
      } else {
        await _showApplianceErrorDialog(context);
      }
    } else {
    }
  }

  Future<void> updateAppliance(
      String applianceId, Map<String, dynamic> updates) async {
    try {
      if (updates.containsKey('applianceName')) {
        updates['applianceName'] = toTitleCase(updates['applianceName']);
      }
      await ApplianceService.updateAppliance(applianceId, updates);
      showSnackBar(context, 'Update Success');
    } catch (e) {
      showSnackBar(context, 'Appliance can only be updated once a month.');
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
          },
        );
      },
    );
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
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void fetchDailyCost() async {
    ApplianceService applianceService = ApplianceService();
    final result = await applianceService.getDaily();

    if (result != null) {
      setState(() {
        dailyCost = result;
      });

    } else {
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
        appliance['selectedDays']?.toString() ?? '';
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
          fetchAppliances: fetchTodayAppliances,
          fetchDailyCosts: fetchDailyCost,
        );
      },
    );
  }

  void _confirmDeleteAppliance(int index) {
    final appliance = appliances[index];
    final applianceProvider = Provider.of<ApplianceProvider>(context,listen: false);

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
                  Icons.warning,
                  color: AppColors.primaryColor,
                  size: 50,
                ),
                const SizedBox(height: 20),
                _popupTitle('Delete Appliance?'),
                const SizedBox(height: 10),
                _popupDescription(
                  'Are you sure you want to delete this appliance? This cannot be undone.',
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
                          fetchTodayAppliances();
                          fetchDailyCost();
                          Navigator.of(context).pop();

                        });
                        Future.delayed(Duration(milliseconds: 1000 ), () {
                          applianceProvider.loadAppliances();
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

  void saveKwhRate(String kwhRate) async {
    try {
      await KWHRateService.saveKwhRate(kwhRate);
    } catch (e) {
    }
  }
}
