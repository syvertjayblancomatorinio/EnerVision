import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
import 'package:supabase_project/CommonWidgets/box-decoration-with-shadow.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/ConstantTexts/final_texts.dart';
import 'package:supabase_project/EnergyPage/YourEnergyCalculator&Compare/AppliancesBrands/aircon.dart';
import 'package:supabase_project/EnergyPage/YourEnergyCalculator&Compare/show_all_your_device.dart';
import 'package:supabase_project/EnergyPage/energy_efficiency_tab/your_energy.dart';

class CompareDevice extends StatelessWidget {
  const CompareDevice({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getAppTheme(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // appBar: customAppBar1(title: 'Compare Device', showProfile: false),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
        body: SafeArea(child: content(context)),
      ),
    );
  }

  Widget content(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          topSection(context),
          compareDeviceWidget(context, 'Aircon', 'assets/dialogImage.png'),
          compareDeviceWidget(context, 'Television', 'assets/dialogImage.png'),
          compareDeviceWidget(context, 'Speakers', 'assets/dialogImage.png'),
        ],
      ),
    );
  }
}

Widget topSection(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: AppColors.primaryColor,
      borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
    ),
    child: Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 35,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ),
            const Spacer(),
            Image.asset('assets/profile (2).png'),
          ],
        ),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search Appliances',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    ),
  );
}

Widget compareDeviceWidget(BuildContext context, String name, String image) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AirConditioner(),
        ),
      );
    },
    child: Container(
      height: 150,
      decoration: greyBoxDecoration(),
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Column to position text at the top-left
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Spacer(),
            // Fixed-size image
            Container(
              child: Image.asset(image),
            ),
          ],
        ),
      ),
    ),
  );
}
