import 'package:flutter/material.dart';

class ApplianceListDialog extends StatelessWidget {
  final List<Map<String, dynamic>> appliances;

  const ApplianceListDialog({
    Key? key,
    required this.appliances,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Appliance List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            appliances.isEmpty
                ? Text(
                    'No appliances added.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  )
                : SizedBox(
                    height: 300, // Adjust height as needed
                    child: ListView.builder(
                      itemCount: appliances.length,
                      itemBuilder: (context, index) {
                        final appliance = appliances[index];
                        return ListTile(
                          leading: Icon(Icons.electrical_services),
                          title: Text(
                            appliance['applianceName'] ?? 'Unknown',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Wattage: ${appliance['wattage']?.toStringAsFixed(2) ?? 'N/A'} W'),
                              Text(
                                  'Monthly Cost: PHP ${appliance['monthlyCost']?.toStringAsFixed(2) ?? 'N/A'}'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
