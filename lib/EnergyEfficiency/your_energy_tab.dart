import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/home_page.dart';

class YourEnergyPageTab extends StatelessWidget {
  YourEnergyPageTab({super.key});

  @override
  Widget build(BuildContext context) {
    double calculateDailyCost = 1;
    double dailyConsumption = 1;

    return const Column(
      children: <Widget>[YourEnergyTab()],
    );
  }
}
