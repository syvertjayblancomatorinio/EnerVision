import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/my_energy_diary_page.dart';
import 'package:supabase_project/EnergyPage/YourEnergyCalculator&Compare/show_all_your_device.dart';
import 'package:supabase_project/EnergyPage/energy_efficiency_tab/Electric-Vehicles-Transportation.dart';
import 'package:supabase_project/EnergyPage/energy_efficiency_tab/energy-storage-systems.dart';
import 'package:supabase_project/EnergyPage/energy_efficiency_tab/fossil-fuels.dart';

class BottomNavigation extends StatefulWidget {
  final int selectedIndex;
  const BottomNavigation({Key? key, required this.selectedIndex});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = -1;

  void _handleTap(int index) {
    setState(() {
      _selectedIndex = index;

      if (index == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyEnergyDiary(selectedIndex: 0),
            // builder: (context) => const YourEnergyPage(),
          ),
        );
      } else if (index == 1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShowAllDevice(
              selectedIndex: 1,
            ),
          ),
        );
      } else if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FossilFuelsWidget(selectedIndex: index),
          ),
        );
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ElectricVehicles(selectedIndex: index),
          ),
        );
      } else if (index == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnergyStorage(selectedIndex: index),
          ),
        );
      }
    });
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
          icon: Icon(
            Icons.home,
          ),
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
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  Color _getTileColor(int index) {
    return _selectedIndex == index
        ? Colors.green.withOpacity(0.2)
        : Colors.white;
  }
}
