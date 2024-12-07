import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:supabase_project/Buttons/energy_efficiency_buttons.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/EnergyManagement/Community/community_tab.dart';
import 'package:supabase_project/EnergyManagement/YourEnergy/your_energy_tab.dart';
import 'package:supabase_project/EnergyManagement/Community/blurred_community_page.dart';
import '../../../CommonWidgets/appbar-widget.dart';
import '../../../CommonWidgets/bottom-navigation-bar.dart';
import '../../../ConstantTexts/Theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../AuthService/models/user_model.dart';

class EnergyEfficiencyPage extends StatefulWidget {
  const EnergyEfficiencyPage({
    super.key,
    required this.selectedIndex,
  });

  final int selectedIndex;

  @override
  _EnergyEfficiencyPageState createState() => _EnergyEfficiencyPageState();
}

class _EnergyEfficiencyPageState extends State<EnergyEfficiencyPage> {
  int _currentIndex = 0;
  String userId = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex >= 0 && widget.selectedIndex <= 2
        ? widget.selectedIndex
        : 0;
    _printUserIdFromPrefs();
  }

  void _onSegmentTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _printUserIdFromPrefs() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    if (currentUser != null) {
      print("Current User ID from Hive: ${currentUser.userId}");
      print("Current Username from Hive: ${currentUser.username}");
      // print("Current Email from Hive: ${currentUser.email}");
    } else {
      print("No user data found in Hive.");
    }
  }
  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_currentIndex) {
      case 0:
        currentPage = YourEnergyPageTab();
        break;
      case 1:
        currentPage = const CommunityTab();
        break;

    // ADDED AN INDEX FOR BLURRED PAGE GUIDELINES
      case 2:
        currentPage = const CommunityTabBlurred();
    //

      default:
        currentPage = YourEnergyPageTab();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          showBackArrow: false,
          showTitle: false,
        ),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                const Text(
                  'Energy Efficiency',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryColor,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 20),
                YourEnergyButtons(
                  selectedIndex: _currentIndex,
                  onSegmentTapped: _onSegmentTapped,
                ),
                const SizedBox(height: 20),
                currentPage,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
