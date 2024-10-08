import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                _buildEnergyPowerUsed(),
                const SizedBox(height: 20),
                _buildKilowattUsage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyPowerUsed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Energy Power Used',
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
                value: monthlyData['totalMonthlyConsumption'] != null
                    ? '₱ ${double.parse(monthlyData['totalMonthlyConsumption'].toString()).toStringAsFixed(2)}'
                    : 'N/A',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String value}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Color(0xFFF0F5F0),
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
