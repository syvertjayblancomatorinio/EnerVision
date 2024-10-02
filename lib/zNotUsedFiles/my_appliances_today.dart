import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAppliancesContent extends StatelessWidget {
  final List<dynamic> appliances;
  final Function(BuildContext, int) onApplianceAction;
  final VoidCallback onAddAppliance;

  const MyAppliancesContent({
    Key? key,
    required this.appliances,
    required this.onApplianceAction,
    required this.onAddAppliance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: appliances.isEmpty
              ? Center(
                  child: Text(
                    'You have no appliances yet',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : ListView(
                  children: appliances.asMap().entries.map((entry) {
                    int index = entry.key;
                    var appliance = entry.value;
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.asset(
                            appliance['imagePath'] ?? 'assets/dialogImage.png',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          appliance['applianceName'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Wattage: ${appliance['wattage'] ?? 'N/A'} watts\nUsage Pattern: ${appliance['usagePattern'] ?? 'N/A'} hours per day',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => onApplianceAction(context, index),
                          child: const Icon(Icons.more_vert),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
          child: Center(
            child: ElevatedButton.icon(
              onPressed: onAddAppliance,
              icon: const Icon(Icons.add, size: 0),
              label: const Text('Add Appliance'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
