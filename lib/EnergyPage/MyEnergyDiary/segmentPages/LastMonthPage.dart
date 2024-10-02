import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/common-widgets.dart';

class LastMonthPage extends StatelessWidget {
  LastMonthPage({super.key});

  @override
  Widget build(BuildContext context) {
    double calculateDailyCost = 1;
    double dailyConsumption = 1;

    return Column(
      children: <Widget>[
        DatePickerWidget(
            initialDate: DateTime.now(), onDateSelected: (date) {}),
        const SizedBox(height: 20),
        // Center(
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       CostKilowatt(calculateDailyCost, 'cost'),
        //       CostKilowatt(dailyConsumption, 'kw'),
        //     ],
        //   ),
        // ),
        const HomeUsage(),
        const SizedBox(height: 40),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            NumberOfAppliances(),
            NumberOfAppliances(),
            NumberOfAppliances(),
          ],
        ),
      ],
    );
  }
}
