import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/AuthService/auth_appliances.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/YourEnergyCalculator&Compare/compare_device.dart';

import '../../CommonWidgets/box_decorations.dart';

class ThisMonthPage extends StatefulWidget {
  @override
  _ThisMonthPageState createState() => _ThisMonthPageState();
}

class _ThisMonthPageState extends State<ThisMonthPage> {
  DateTime selectedDate = DateTime.now();
  late String formattedDate;
  Map<String, dynamic> monthlyData = {};
  late int totalDevices = 0;
  late double co2Emission = 0.0;
  final List<dynamic> devices = [];
  double estimatedEnergy = 0.0;
  bool isLoading = false;
  List<Map<String, dynamic>> appliances = [];

  @override
  void initState() {
    super.initState();
    fetchAppliances();
    totalMonthlyCostOfUserAppliances();
  }

  Future<void> totalMonthlyCostOfUserAppliances() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is null. Cannot fetch total monthly cost.");
      return;
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
      print('Fetched total monthly cost: ${monthlyData['totalMonthlyCost']}');
    } else {
      print('Failed to fetch total monthly cost: ${response.statusCode}');
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
      _showSnackBar('Appliance are available');
    } catch (e) {
      print('Error: $e');
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Device Usage Summary on the left
                    Expanded(
                      flex: 1,
                      child: deviceUsageSummary(
                        totalDevices: totalDevices,
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
            thumbColor: MaterialStateProperty.all(AppColors.primaryColor),
            trackColor:
                MaterialStateProperty.all(Colors.grey[300]), // Track color
            trackBorderColor: MaterialStateProperty.all(Colors.transparent),
            thickness: MaterialStateProperty.all(10), // Adjust thickness
            radius: const Radius.circular(20), // Rounded edges
            thumbVisibility:
                MaterialStateProperty.all(true), // Always show the scrollbar
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
    required int totalDevices,
    required double co2Emission,
    required double estimatedEnergy,
  }) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            energyCard(title: "Total Devices", value: totalDevices.toString()),
            const SizedBox(height: 16),
            energyCard(
                title: "CO2 Emission", value: co2Emission.toStringAsFixed(2)),
            const SizedBox(height: 16),
            energyCard(
              title: "Estimated Energy Used",
              value: "${estimatedEnergy.toStringAsFixed(2)} kW",
            ),
            const SizedBox(height: 16),
            energyCard(
              title: "Estimated Energy Used",
              value: "${estimatedEnergy.toStringAsFixed(2)} kW",
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
            Text(
              value,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 10.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: const Color(0xFFF0F5F0),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyPowerUsed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Home Usage',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                title: 'CO2 Emission',
                value: monthlyData['totalMonthlyCO2Emissions'] != null
                    ? '${double.parse(monthlyData['totalMonthlyCO2Emissions'].toString()).toStringAsFixed(2)}'
                    : 'N/A',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildInfoCard(
                title: 'Estimated Cost',
                value: monthlyData['totalMonthlyCost'] != null
                    ? '₱ ${double.parse(monthlyData['totalMonthlyCost'].toString()).toStringAsFixed(2)}'
                    : 'N/A',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKilowattUsage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'So far, this month kilowatt per hour used',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _buildInfoCard(
          title: 'Kilowatt Usage',
          value: monthlyData['totalMonthlyKwhConsumption'] != null
              ? '${double.parse(monthlyData['totalMonthlyKwhConsumption'].toString()).toStringAsFixed(2)} kWh'
              : 'N/A',
        ),
      ],
    );
  }
}
