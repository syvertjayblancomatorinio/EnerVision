import 'package:flutter/material.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/common-widgets.dart';
import '../../CommonWidgets/appbar-widget.dart';
import '../../CommonWidgets/bottom-navigation-bar.dart';
import '../../ConstantTexts/Theme.dart';
import 'segmentPages/LastMonthPage.dart';
import 'segmentPages/this_month_page.dart';
import 'segmentPages/today.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyEnergyDiary extends StatefulWidget {
  const MyEnergyDiary({super.key, required this.selectedIndex});

  final int selectedIndex;

  @override
  _MyEnergyDiaryState createState() => _MyEnergyDiaryState();
}

class _MyEnergyDiaryState extends State<MyEnergyDiary> {
  int _currentIndex = 1;
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
        currentPage = LastMonthPage();
        break;
      case 1:
        currentPage = TodayPage(); // Pass the user ID
        break;
      case 2:
        currentPage = ThisMonthPage();
        break;
      default:
        currentPage = TodayPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(title: 'My Energy Diary'),
        bottomNavigationBar: const BottomNavigation(selectedIndex: 0),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                EnergyDiaryButtons(
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
