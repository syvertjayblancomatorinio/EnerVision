import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/box-decoration-with-shadow.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/ConstantTexts/final_texts.dart';
import 'package:supabase_project/EnergyPage/YourEnergyCalculator&Compare/compare_two_device.dart';

class AirConditioner extends StatelessWidget {
  const AirConditioner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          title: 'Air Conditioner',
          showProfile: false,
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: content(context),
      ),
    );
  }
}

Widget content(BuildContext context) {
  return Center(
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
          child: Text(
            appliancePageExplainer,
            textAlign: TextAlign.center,
            style: TextStyle(),
          ),
        ),
        airconContainer(context),
      ],
    ),
  );
}

Widget airconContainer(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    width: 350,
    height: 120,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Carrier XPower Gold 3',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Est. Monthly Cost:  ₱2,112 - ₱4,224',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              Text(
                'Price range:  ₱48,800 - ₱79,700',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 100,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Image.asset(
                  'assets/energy1.png',
                  width: 100,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompareTwoDevices(),
                      ),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                        color: AppColors.primaryColor, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
