import 'package:flutter/material.dart';
import 'package:supabase_project/Buttons/energy_efficiency_buttons.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/box-decoration-with-shadow.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/EnergyPage/energy_efficiency_tab/Electric-Vehicles-Transportation.dart';
import 'package:supabase_project/EnergyPage/energy_efficiency_tab/energy-effieciency-widget.dart';
import 'package:supabase_project/EnergyPage/energy_efficiency_tab/fossil-fuels.dart';
import 'package:supabase_project/EnergyPage/energy_efficiency_tab/renewable-energy.dart';

import '../YourEnergyCalculator&Compare/energy_tracker.dart';
import 'energy-storage-systems.dart';

class YourEnergyPage extends StatefulWidget {
  const YourEnergyPage({super.key});

  @override
  State<YourEnergyPage> createState() => _YourEnergyPageState();
}

class _YourEnergyPageState extends State<YourEnergyPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          title: 'Energy Efficiency',
        ),
        body: content(context),
      ),
    );
  }
}

Widget content(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: <Widget>[
        const Text('Energy Efficiency'),
        Center(
            child: EnergyDiaryButtons(
                selectedIndex: 1, onSegmentTapped: (int value) {})),
        yourEnergyContent(context),
        optimizeEnergyUsage(context),
      ],
    ),
  );
}

Widget yourEnergyContent(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0), // Padding around the entire content
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Welcome to EnerVision, ready to save energy?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.start),
        const SizedBox(height: 20),
        TextField(
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
        const SizedBox(height: 20),
        const Text(
          'Category Story Tags',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
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
              storyTag(
                  'Solar Energy',
                  context,
                  const FossilFuelsWidget(
                    selectedIndex: 1,
                  )),
              storyTag('EnergyStorage', context,
                  const EnergyStorage(selectedIndex: 1)),
              storyTag('Energy Efficiency Widget', context,
                  const EnergyEfficiencyWidget(selectedIndex: 1)),
              storyTag('Electric Vehicles', context,
                  const ElectricVehicles(selectedIndex: 1)),
            ],
          ),
        ),
        const Text(
          'Energy Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
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
              storyTag(
                  'Solar Energy',
                  context,
                  const FossilFuelsWidget(
                    selectedIndex: 1,
                  )),
              storyTag('EnergyStorage', context,
                  const EnergyStorage(selectedIndex: 1)),
              storyTag('Energy Efficiency Widget', context,
                  const EnergyEfficiencyWidget(selectedIndex: 1)),
              storyTag('Electric Vehicles', context,
                  const ElectricVehicles(selectedIndex: 1)),
            ],
          ),
        ),
        const Divider(height: 40, color: Colors.grey),
      ],
    ),
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
    width: 270,
    height: 116,
    margin: const EdgeInsets.symmetric(vertical: 20),
    decoration: greyBoxDecoration(),
    child: Center(
      child: Column(
        children: [
          const Text(
            'Optimize Energy Usage',
          ),
          const Text(
            'Analyze energy consumption for efficiency',
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: () {
              // Use Navigator to push the new page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnergyTracker()),
              );
            },
            child: const Text('Track now'),
          )
        ],
      ),
    ),
  );
}
