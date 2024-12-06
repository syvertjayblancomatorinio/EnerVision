import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_project/PreCode/Provider/ApplianceProvider.dart';

import '../../CommonWidgets/bottom-navigation-bar.dart';

class ApplianceListPage extends StatefulWidget {
  @override
  _ApplianceListPageState createState() => _ApplianceListPageState();
}

class _ApplianceListPageState extends State<ApplianceListPage> {
  @override
  void initState() {
    super.initState();
    // Call the loadAppliances method after the page is opened.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final applianceProvider = Provider.of<ApplianceProvider>(context, listen: false);
      applianceProvider.loadAppliances();
    });
  }

  @override
  Widget build(BuildContext context) {
    final applianceProvider = Provider.of<ApplianceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Appliances')),
      bottomNavigationBar: const BottomNavigation(selectedIndex: 3),
      body: applianceProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: applianceProvider.appliances.length,
        itemBuilder: (context, index) {
          final appliance = applianceProvider.appliances[index];
          return ListTile(
            title: Text(appliance['applianceName']),
            subtitle: Text('Wattage: ${appliance['wattage']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => applianceProvider.loadAppliances(),
        child: Icon(Icons.refresh),
      ),
    );
  }
}
