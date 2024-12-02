import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/AuthService/base_url.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/CommonWidgets/dialogs/appliance_information_dialog.dart';
import 'package:supabase_project/CommonWidgets/dialogs/error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_project/CommonWidgets/dialogs/number_of_appliances_dialog.dart';
import 'package:supabase_project/MyEnergyDiary/common-widgets.dart';
import 'package:supabase_project/MyEnergyDiary/date_picker.dart';
import 'package:supabase_project/MyEnergyDiary/date_picker_new_ui.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../../CommonWidgets/appliance_container/total_cost&kwh.dart';
import '../../ConstantTexts/colors.dart';

class LastMonthPage extends StatefulWidget {
  const LastMonthPage({super.key});

  @override
  State<LastMonthPage> createState() => _LastMonthPageState();
}

class _LastMonthPageState extends State<LastMonthPage> {
  Map<String, dynamic> monthlyData = {};
  int applianceCount = 0;
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> appliances = [];
  final AppControllers controllers = AppControllers();
  Map<String, double> dataMap = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getUsersApplianceCount();
    DateTime now = DateTime.now();
    selectedDate = DateTime(now.year, now.month - 1, now.day);
    if (now.month == 1) {
      selectedDate = DateTime(now.year - 1, 12, now.day);
    }
    getLastMonth(selectedDate);
  }

  void showApplianceInformationDialog(BuildContext context) {
    if (appliances.isEmpty) {
      print('No appliances to show.');
    }

    showDialog(
      context: context,
      builder: (context) {
        return ApplianceListDialog(appliances: appliances);
      },
    );
  }


  Future<void> getUsersApplianceCount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is null. Cannot fetch appliance count.");
      return;
    }

    final formattedMonth = DateFormat('MM').format(selectedDate);
    final formattedYear = DateFormat('yyyy').format(selectedDate);

    final response = await http.get(Uri.parse(
        '${ApiConfig.baseUrl}/getNewUsersCount/$userId/appliances?month=$formattedMonth&year=$formattedYear'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        applianceCount = data['count'] ?? 0;
        appliances = List<Map<String, dynamic>>.from(data['appliances'] ?? []);
        dataMap = {
          for (var appliance in appliances)
            if (appliance["monthlyCost"] != null &&
                appliance["applianceName"] != null)
              appliance["applianceName"]: (appliance["monthlyCost"] is int
                  ? (appliance["monthlyCost"] as int).toDouble()
                  : appliance["monthlyCost"]) as double
        };
      });
    } else {
      throw Exception('Failed to load appliances');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DatePickerWidget(
          initialDate: selectedDate,
          onDateSelected: onDateSelected,
          getApplianceCount: getUsersApplianceCount,
        ),
        const SizedBox(height: 20),
        HomeUsage(
          kwh: monthlyData['totalMonthlyKwhConsumption'] != null
              ? '${double.parse(monthlyData['totalMonthlyKwhConsumption'].toString()).toStringAsFixed(2)} kwh'
              : 'N/A',
        ),
        const SizedBox(height: 40),
        bottomPart(),
        chart(),
      ],
    );
  }

  Widget chart() {
    return SafeArea(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : appliances.isEmpty
              ? const Center(child: Text("No data available."))
              : Container(
                  margin: const EdgeInsets.symmetric(vertical: 100),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          dataMap.isNotEmpty
                              ? PieChart(
                                  dataMap: dataMap,
                                  animationDuration:
                                      const Duration(milliseconds: 500),
                                  chartLegendSpacing: 30,
                                  chartRadius:
                                      MediaQuery.of(context).size.width / 1.5,
                                  colorList: colorList,
                                  initialAngleInDegree: 0,
                                  chartType: ChartType.ring,
                                  ringStrokeWidth: 32,
                                  centerText: "Appliances",
                                  legendOptions: const LegendOptions(
                                    showLegendsInRow: false,
                                    legendPosition: LegendPosition.right,
                                    showLegends: true,
                                    legendShape: BoxShape.circle,
                                    legendTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  chartValuesOptions: const ChartValuesOptions(
                                    showChartValueBackground: true,
                                    showChartValues: true,
                                    showChartValuesInPercentage: true,
                                    showChartValuesOutside: true,
                                    decimalPlaces: 1,
                                  ),
                                )
                              : const Center(child: Text("No data to display")),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget bottomPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            print('Appliances tapped');
            showApplianceInformationDialog(context);
          },
          child: ApplianceInfoCard(
            imagePath: 'assets/image (7).png',
            mainText: applianceCount.toString(),
            subText: 'No. of Appliances Added',
          ),
        ),
        ApplianceInfoCard(
          imagePath: 'assets/image (9).png',
          mainText: monthlyData['totalMonthlyConsumption'] != null
              ? double.parse(monthlyData['totalMonthlyConsumption'].toString())
                  .toStringAsFixed(2)
              : 'N/A',
          subText: 'Estimated Total Cost for the Month',
        ),
        ApplianceInfoCard(
          imagePath: 'assets/image (8).png',
          mainText: monthlyData['totalMonthlyCO2Emission'] != null
              ? double.parse(monthlyData['totalMonthlyCO2Emission'].toString())
                  .toStringAsFixed(2)
              : 'N/A',
          subText: 'CO2 Emission',
        ),
      ],
    );
  }

  Future<void> _showApplianceErrorDialog(BuildContext context) async {
    await showCustomDialog(
      context: context,
      title: 'No data available',
      message:
          'No data available for this month or year. \nPlease use a different date.',
      buttonText: 'OK',
    );
  }

  Future<void> getLastMonth(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is null. Cannot fetch monthly consumption.");
      return;
    }

    final formattedMonth = DateFormat('MM').format(date);
    final formattedYear = DateFormat('yyyy').format(date);

    final url = Uri.parse(
        "${ApiConfig.baseUrl}/monthlyDataNew/$userId?month=$formattedMonth&year=$formattedYear");

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 404) {
        setState(() {
          monthlyData = {
            'totalMonthlyConsumption': null,
            'totalMonthlyKwhConsumption': null,
          };
        });
        await _showApplianceErrorDialog(context);
        return;
      } else if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double totalMonthlyConsumption =
            data['data']['totalMonthlyConsumption']?.toDouble() ?? 0.0;

        // Fetch user's kwhRate from a reliable source
        final double kwhRate = await getUserKwhRate(userId);

        // Calculate totalKwhConsumption
        double totalKwhConsumption =
            (kwhRate > 0) ? totalMonthlyConsumption / kwhRate : 0.0;
        double totalCO2Emission = totalKwhConsumption * 0.7;
        setState(() {
          monthlyData = {
            'totalMonthlyConsumption': totalMonthlyConsumption,
            'totalMonthlyKwhConsumption': totalKwhConsumption,
            'totalMonthlyCO2Emission': totalCO2Emission,
          };
        });
        print("Monthly Data: $monthlyData");
      } else {
        print(
            "Failed to load monthly data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching monthly data: $e");
    }
  }

  Future<double> getUserKwhRate(String userId) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/user/$userId/kwhRate");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['kwhRate']?.toDouble() ?? 0.0;
      } else {
        print("Failed to fetch kwhRate. Status code: ${response.statusCode}");
        return 0.0;
      }
    } catch (e) {
      print("Error fetching kwhRate: $e");
      return 0.0;
    }
  }

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    getLastMonth(date);
  }
}
