import 'package:flutter/material.dart';
import 'package:supabase_project/Buttons/energy_efficiency_buttons.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/common-widgets.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/segmentPages/LastMonthPage.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/segmentPages/this_month_page.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/segmentPages/today.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/EnergyEfficiency/your_energy_tab.dart';
import '../../CommonWidgets/appbar-widget.dart';
import '../../CommonWidgets/bottom-navigation-bar.dart';
import '../../ConstantTexts/Theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnergyEffieciencyPage extends StatefulWidget {
  const EnergyEffieciencyPage({
    super.key,
    required this.selectedIndex,
  });

  final int selectedIndex;
  @override
  _EnergyEffieciencyPageState createState() => _EnergyEffieciencyPageState();
}

class _EnergyEffieciencyPageState extends State<EnergyEffieciencyPage> {
  int _currentIndex = 0;
  String userId = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex >= 0 && widget.selectedIndex <= 2
        ? widget.selectedIndex
        : 0;

    _loadUserId(); // Load the user ID
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
    });
  }

  void _onSegmentTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (_currentIndex) {
      case 0:
        currentPage = YourEnergyPageTab();
        break;
      case 1:
        currentPage = const TodayPage();
        break;
      default:
        currentPage = YourEnergyPageTab();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar2(
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
