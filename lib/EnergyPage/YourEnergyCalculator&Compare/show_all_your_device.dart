import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/CommonWidgets/box-decoration-with-shadow.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/EnergyPage/YourEnergyCalculator&Compare/compare_device.dart';
import 'package:supabase_project/MockData/data/appliances.dart';

class ShowAllDevice extends StatelessWidget {
  final int selectedIndex;

  const ShowAllDevice({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          title: 'All Devices',
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 2),
        body: content(context),
      ),
    );
  }
}

Widget content(BuildContext context) {
  return Stack(
    children: [
      SingleChildScrollView(
        child: Column(
          children: mockAppliances.map((device) {
            return deviceWidget(
              name: device['name'],
              wattage: device['wattage'].toDouble(),
              usagePattern: device['usagePatternPerMonth'].toDouble(),
              month: device['usagePatternPerMonth'].toDouble(),
              context: context,
            );
          }).toList(),
        ),
      ),
      Positioned(
        bottom: 20.0,
        right: 20.0,
        child: ElevatedButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    ],
  );
}

Widget deviceWidget({
  required String name,
  required double wattage,
  required double usagePattern,
  required double month,
  required BuildContext context,
}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        margin: const EdgeInsets.all(20),
        decoration: greyBoxDecoration(),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
        child: Column(
          children: [
            Text(name),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    const Icon(Icons.energy_savings_leaf),
                    const SizedBox(width: 5),
                    Text('$wattage W'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.watch_later_outlined),
                    const SizedBox(width: 5),
                    Text('$usagePattern W'),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined),
                    const SizedBox(width: 5),
                    Text('$month'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      Positioned(
        top: 0,
        left: 20,
        child: Image.asset(
          'assets/deviceImage.png',
          width: 102,
          height: 86,
        ),
      ),
      Positioned(
        bottom: -5,
        right: 30,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CompareDevice(),
              ),
            );
          },
          child: const Text('Compare'),
        ),
      ),
    ],
  );
}
