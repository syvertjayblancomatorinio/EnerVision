import 'package:supabase_project/EnergyManagement/Community/energy_effieciency_page.dart';
import 'package:supabase_project/EnergyPage/offline_calculator_v2.dart';
import 'package:supabase_project/Goals/goals.dart';
import 'package:supabase_project/MyEnergyDiary/segmentPages/my_energy_diary_page.dart';
import 'package:supabase_project/PreCode/Provider/ApplianceWidget.dart';
import 'package:supabase_project/PreCode/accountpagewithprofile.dart';
import 'package:supabase_project/Settings/app-settings-widget.dart';
import 'package:supabase_project/practice_back_tap.dart';

import '../MyEnergyDiary/all_devices_page.dart';
import '../all_imports/imports.dart';
import '../main.dart';

class BottomNavigation extends StatefulWidget {
  final int selectedIndex;
  const BottomNavigation({Key? key, required this.selectedIndex});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  // Handle tap event for bottom navigation bar
  void _handleTap(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation based on selected index
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EnergyEfficiencyPage(selectedIndex: 0),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyEnergyDiary(
            selectedIndex: 1,
          ),
        ),
      );
    } else if (index == 2) {
      String? userId = await UserService.getUserId();  // Get userId before navigating
      if (userId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllDevicesPage(userId: userId),
          ),
        );
      }
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  GoalsPage()),
      );

    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AppSettings(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return customBottomNavigationBar1(onTap: _handleTap);
  }

  BottomNavigationBar customBottomNavigationBar1(
      {required Function(int) onTap}) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryColor,
      currentIndex: widget.selectedIndex,
      onTap: onTap,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.commute),
          label: 'Energy',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.crisis_alert_outlined),
          label: 'Goals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
