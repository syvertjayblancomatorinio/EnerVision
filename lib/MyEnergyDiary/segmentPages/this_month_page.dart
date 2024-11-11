import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/AuthService/auth_appliances.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

class ThisMonthPage extends StatefulWidget {
  const ThisMonthPage({super.key});

  @override
  _ThisMonthPageState createState() => _ThisMonthPageState();
}

class _ThisMonthPageState extends State<ThisMonthPage> {
  DateTime selectedDate = DateTime.now();
  late String formattedDate;
  late int applianceCount = 0;
  late double co2Emission = 0.0;
  late double estimatedEnergy = 0.0;
  final List<dynamic> devices = [];
  Map<String, dynamic> monthlyData = {};
  List<Map<String, dynamic>> appliances = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAppliances();
    totalMonthlyCostOfUserAppliances();
    getUsersApplianceCount();
  }

  Future<void> getUsersApplianceCount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception("User ID is null. Cannot fetch appliance count.");
    }

    // Adjust the URL to match the new endpoint
    final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/getUsersCount/$userId/appliances'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        // Check if the appliances are included in the response
        if (data['appliances'] != null) {
          // Update the applianceCount variable based on the length of the appliances list
          applianceCount = data['appliances'].length;
        } else {
          applianceCount = 0; // Set to 0 if no appliances found
        }
      });
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  Future<void> totalMonthlyCostOfUserAppliances() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception("User ID is null. Cannot fetch total monthly cost.");
    }

    final url = Uri.parse(
        "http://10.0.2.2:8080/totalMonthlyCostOfUserAppliances/$userId");

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        monthlyData['totalMonthlyCost'] = data['totalMonthlyCost'];
        monthlyData['totalMonthlyKwhConsumption'] =
            data['totalMonthlyKwhConsumption'];
        monthlyData['totalMonthlyCO2Emissions'] =
            data['totalMonthlyCO2Emissions'];
      });
      throw Exception(
          'Fetched total monthly cost: ${monthlyData['totalMonthlyCost']}');
    } else {
      throw Exception(
          'Failed to fetch total monthly cost: ${response.statusCode}');
    }
  }

  Future<void> fetchAppliances() async {
    setState(() {
      isLoading = true;
    });

    try {
      final appliancesData = await ApplianceService.fetchAppliance();
      setState(() {
        appliances = List<Map<String, dynamic>>.from(appliancesData);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Home Usage',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                headers(),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Device Usage Summary on the left
                    Expanded(
                      flex: 1,
                      child: deviceUsageSummary(
                        applianceCount: applianceCount,
                        co2Emission: co2Emission,
                        estimatedEnergy: estimatedEnergy,
                      ),
                    ),
                    const SizedBox(width: 20),

                    Expanded(
                      flex: 2,
                      child: appliancesContent(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget headers() {
    return const Row(
      children: [
        Text(
          'Device Usage Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        Text(
          'Devices',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor),
        ),
      ],
    );
  }

  Widget applianceContentNew() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Devices',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor),
        ),
        const SizedBox(height: 20),
        appliancesContent(),
      ],
    );
  }

  Widget appliancesContent() {
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
      return Container(
        padding: const EdgeInsets.all(10),
        // decoration: greyBoxDecoration(),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFADE7DB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        height: 450,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thumbColor: WidgetStateProperty.all(AppColors.primaryColor),
            trackColor:
                WidgetStateProperty.all(Colors.grey[300]), // Track color
            trackBorderColor: WidgetStateProperty.all(Colors.transparent),
            thickness: WidgetStateProperty.all(10), // Adjust thickness
            radius: const Radius.circular(20), // Rounded edges
            thumbVisibility:
                WidgetStateProperty.all(true), // Always show the scrollbar
          ),
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView(
              children: appliances.asMap().entries.map((entry) {
                var appliance = entry.value;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: const Color(0xFFADE7DB),
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x40000000),
                                offset: Offset(0, 4),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          width: MediaQuery.of(context).size.width * 0.472,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${appliance['applianceName'] ?? 'Unknown'}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        const SizedBox(width: 5),
                                        Text(
                                          'PHP ${appliance['monthlyCost'].toStringAsFixed(2) ?? 'N/A'}',
                                          style: const TextStyle(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Monthly Cost",
                                          style: TextStyle(
                                            fontSize: 8.0,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            const SizedBox(width: 5),
                                            Text(
                                              '${appliance['wattage'].toStringAsFixed(2) ?? 'N/A'}',
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "Wattage",
                                              style: TextStyle(
                                                fontSize: 8.0,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
    }
  }

  Widget deviceUsageSummary({
    required int applianceCount,
    required double co2Emission,
    required double estimatedEnergy,
  }) {
    return Row(
      children: [
        Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                energyCard(
                  title: "Total Devices",
                  value: applianceCount.toString(),

                  // value: totalDevices.toString(),
                ),
                const SizedBox(height: 16),
                energyCard(
                  title: "CO2 Emission",
                  value: monthlyData['totalMonthlyCO2Emissions'] != null
                      ? double.parse(monthlyData['totalMonthlyCO2Emissions']
                              .toString())
                          .toStringAsFixed(2)
                      : 'N/A',
                ),
                const SizedBox(height: 16),
                energyCard(
                  title: "Estimated Energy Used",
                  value: monthlyData['totalMonthlyKwhConsumption'] != null
                      ? '${double.parse(monthlyData['totalMonthlyKwhConsumption'].toString()).toStringAsFixed(2)} kWh'
                      : 'N/A',
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onPanDown: (details) {
                    // This is triggered when the user touches the screen and starts panning.
                    print(
                        'User touched the screen at: ${details.localPosition}');
                  },
                  child: energyCard(
                    title: "Estimated Monthly Cost",
                    value: monthlyData['totalMonthlyCost'] != null
                        ? 'PHP ${double.parse(monthlyData['totalMonthlyCost'].toString()).toStringAsFixed(2)}'
                        : 'N/A',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget energyCard({required String title, required String value}) {
    return SizedBox(
      width: 117,
      height: 100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFADE7DB),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1, // Limit to 1 line for value
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Limit to 2 lines for title
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
