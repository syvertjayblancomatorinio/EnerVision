import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/CommonWidgets/dialogs/error_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_project/MyEnergyDiary/common-widgets.dart';

import '../../../CommonWidgets/appliance_container/total_cost&kwh.dart';

class LastMonthPage extends StatefulWidget {
  const LastMonthPage({super.key});

  @override
  State<LastMonthPage> createState() => _LastMonthPageState();
}

class _LastMonthPageState extends State<LastMonthPage> {
  Map<String, dynamic> monthlyData = {};
  int applianceCount = 0; // Renamed for clarity
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    getLastMonth(selectedDate);
    getUsersApplianceCount(); // Fetching the appliance count during init
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

  Future<void> getUsersApplianceCount() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is null. Cannot fetch appliance count.");
      return;
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

  Future<void> getLastMonth(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is null. Cannot fetch monthly consumption.");
      return;
    }

    final formattedMonth = DateFormat('MM').format(date); // Get month as "MM"
    final formattedYear = DateFormat('yyyy').format(date); // Get year as "yyyy"

    final url = Uri.parse(
        "http://10.0.2.2:8080/monthlyDataNew/$userId?month=$formattedMonth&year=$formattedYear");

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 404) {
        // Reset monthlyData to default values when 404 occurs
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
        final double kwhRate = await getUserKwhRate(
            userId); // Assuming this method retrieves the kwhRate

        // Calculate totalKwhConsumption
        double totalKwhConsumption =
            (kwhRate > 0) ? totalMonthlyConsumption / kwhRate : 0.0;

        setState(() {
          monthlyData = {
            'totalMonthlyConsumption': totalMonthlyConsumption,
            'totalMonthlyKwhConsumption': totalKwhConsumption,
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
    final url = Uri.parse("http://10.0.2.2:8080/user/$userId/kwhRate");
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

  Future<void> saveUserKwhRate(double kwhRate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('kwhRate', kwhRate);
  }

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    getLastMonth(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        DatePickerWidget(
            initialDate: selectedDate, onDateSelected: onDateSelected),
        const SizedBox(height: 20),
        HomeUsage(
          kwh: monthlyData['totalMonthlyKwhConsumption'] != null
              ? '${double.parse(monthlyData['totalMonthlyKwhConsumption'].toString()).toStringAsFixed(2)} kwh'
              : 'N/A',
        ),
        const SizedBox(height: 40),
        bottomPart(),
      ],
    );
  }

  Widget bottomPart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ApplianceInfoCard(
          imagePath: 'assets/image (7).png',
          mainText: applianceCount.toString(), // Number of appliances
          subText: 'No. of Appliances Added',
        ),
        ApplianceInfoCard(
          imagePath: 'assets/image (9).png',
          mainText: monthlyData['totalMonthlyConsumption'] != null
              ? double.parse(monthlyData['totalMonthlyConsumption'].toString())
                  .toStringAsFixed(2)
              : 'N/A',
          subText: 'Estimated Total Cost for the Month',
        ),
        const ApplianceInfoCard(
          imagePath: 'assets/image (8).png',
          mainText: '10', // You may want to replace this with dynamic data
          subText: 'Peak Usage Time',
        ),
      ],
    );
  }
}
