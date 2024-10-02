import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_project/Buttons/energy_efficiency_buttons.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/all_devices_page.dart';
import 'package:supabase_project/zNotUsedFiles/show_all_your_device.dart';

import '../EnergyPage/EnergyTracker/energy_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../StaticPages/energy_efficiency_tab/Electric-Vehicles-Transportation.dart';
import '../StaticPages/energy_efficiency_tab/energy-effieciency-widget.dart';
import '../StaticPages/energy_efficiency_tab/energy-storage-systems.dart';
import '../StaticPages/energy_efficiency_tab/fossil-fuels.dart';
import '../StaticPages/energy_efficiency_tab/renewable-energy.dart';

class YourEnergyTab extends StatefulWidget {
  const YourEnergyTab({super.key});

  @override
  State<YourEnergyTab> createState() => _YourEnergyTabState();
}

class _YourEnergyTabState extends State<YourEnergyTab> {
  String? userId;

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final url = Uri.parse("http://10.0.2.2:8080/getUserProfile?userId=$userId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        content(context),
      ],
    );
  }
}

Widget content(BuildContext context) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          yourEnergyContent(context),
          optimizeEnergyUsage(context),
        ],
      ),
    ),
  );
}

Widget yourEnergyContent(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Welcome to EnerVision,\n ready to save energy?',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w900, color: Colors.grey),
        ),
      ),
      const SizedBox(height: 20),
      searchTextField(),
      const SizedBox(height: 20),
      categoryStoryTags(context),
      const SizedBox(height: 20),
      energyCategories(context),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Divider(height: 40, color: Colors.grey),
      ),
    ],
  );
}

Widget searchTextField() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    ),
  );
}

Widget title(
  String title,
) {
  return Column(
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget categoryStoryTags(BuildContext context) {
  return Column(
    children: [
      title('Category Story Tags'),
      const SizedBox(height: 20),
      Center(
        // Center the Wrap widget
        child: Wrap(
          spacing: 20.0,
          runSpacing: 20.0,
          alignment: WrapAlignment.center,
          children: [
            storyTag('Renewable Energy', context,
                const RenewableEnergy(selectedIndex: 1)),
            storyTag('Solar Energy', context, const FossilFuelsWidget()),
            storyTag('EnergyStorage', context,
                const EnergyStorage(selectedIndex: 1)),
            storyTag('Energy Efficiency Widget', context,
                const EnergyEfficiencyWidget(selectedIndex: 1)),
            storyTag('Electric Vehicles', context,
                const ElectricVehicles(selectedIndex: 1)),
          ],
        ),
      ),
    ],
  );
}

Widget energyCategories(BuildContext context) {
  return Column(
    children: [
      title('Energy Categories'),
      const SizedBox(height: 20),
      Center(
        // Center the Wrap widget
        child: Wrap(
          spacing: 20.0,
          runSpacing: 20.0,
          alignment: WrapAlignment.center, // Center the children horizontally
          children: [
            storyTag('Renewable Energy', context,
                const RenewableEnergy(selectedIndex: 1)),
            storyTag('Solar Energy', context, const FossilFuelsWidget()),
            storyTag('EnergyStorage', context,
                const EnergyStorage(selectedIndex: 1)),
            storyTag('Energy Efficiency Widget', context,
                const EnergyEfficiencyWidget(selectedIndex: 1)),
            storyTag('Electric Vehicles', context,
                const ElectricVehicles(selectedIndex: 1)),
          ],
        ),
      ),
    ],
  );
}

Widget storyTag(String title, BuildContext context, Widget page) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    },
    child: Container(
      width: 120, // Width of each tag
      height: 70, // Height of each tag
      padding: const EdgeInsets.all(8.0), // Padding inside the container
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/deviceImage.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3,
                color: Colors.black45,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

Widget optimizeEnergyUsage(BuildContext context) {
  return Container(
    decoration: greyBoxDecoration(),
    padding: const EdgeInsets.all(10),
    margin: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // const Text(
        //   'Optimize Energy Usage',
        //   style: TextStyle(
        //     fontSize: 18,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: title('Optimize Energy Usage'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Analyze energy consumption for efficiency',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // Use Navigator to push the new page
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AllDevicesPage(
                        userId: '',
                      )),
            );
          },
          child: const Text('Track now'),
        )
      ],
    ),
  );
}
