import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/total_cost&kwh.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/common-widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThisMonthPage extends StatefulWidget {
  @override
  _ThisMonthPageState createState() => _ThisMonthPageState();
}

class _ThisMonthPageState extends State<ThisMonthPage> {
  DateTime selectedDate = DateTime.now();
  late String formattedDate;
  Map<String, dynamic> monthlyData = {};

  @override
  void initState() {
    super.initState();
    getMonthly();
    // formattedDate = DateFormat('MMMM yyyy').format(selectedDate);
  }

  Future<void> getMonthly() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is null. Cannot fetch monthly consumption.");
      return;
    }

    final url = Uri.parse("http://10.0.2.2:8080/totalDailyData/$userId");

    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        monthlyData = {
          'totalMonthlyCO2Emissions': data['totalMonthlyCO2Emissions'],
          'totalMonthlyConsumption': data['totalMonthlyConsumption'],
          'totalMonthlyKwhConsumption': data['totalMonthlyKwhConsumption'],
        };
      });
      print(
          'Fetched totalMonthlyConsumption: ${monthlyData['totalMonthlyConsumption']}');
      print(
          'Fetched totalMonthlyKwhConsumption: ${monthlyData['totalMonthlyKwhConsumption']}');
    } else {
      print('Failed to fetch totalMonthlyConsumption: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),
        Container(
          decoration: greyBoxDecoration(),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              totalCostDisplay(),
              const SizedBox(height: 30),
              energyPowerUsed(),
            ],
          ),
        ),
      ],
    );
  }

  Widget totalCostDisplay() {
    return Column(
      children: [
        TotalCostDisplay(
          cost: monthlyData['totalMonthlyKwhConsumption'] != null
              ? '${double.parse(monthlyData['totalMonthlyKwhConsumption'].toString()).toStringAsFixed(2)} kwh'
              : 'N/A',
        ),
        const SizedBox(height: 20),
        const Text(
          'So far, this month kilowatt per hour used',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  Widget energyPowerUsed() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Energy Power Used. ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            EstimatedDisplay(
              cost: monthlyData['totalMonthlyCO2Emissions'] != null
                  ? double.parse(
                          monthlyData['totalMonthlyCO2Emissions'].toString())
                      .toStringAsFixed(2)
                  : 'N/A',
              texts: 'C02 Emission',
            ),
            EstimatedDisplay(
              cost: monthlyData['totalMonthlyConsumption'] != null
                  ? '₱ ${double.parse(monthlyData['totalMonthlyConsumption'].toString()).toStringAsFixed(2)} '
                  : 'N/A',
              texts: 'Monthly Cost',
            ),
          ],
        )
      ],
    );
  }
}
