// appliance_tile.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ApplianceTile extends StatelessWidget {
  final String imagePath;
  final String applianceName;
  final String wattage;
  final String usagePattern;
  final VoidCallback onMoreOptions;

  const ApplianceTile({
    Key? key,
    required this.imagePath,
    required this.applianceName,
    required this.wattage,
    required this.usagePattern,
    required this.onMoreOptions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
        leading: Image.asset(imagePath),
        title: Text(applianceName),
        subtitle: Text('Wattage: $wattage\nUsage Pattern: $usagePattern'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onMoreOptions,
          child: const Icon(Icons.more_vert),
        ),
      ),
    );
  }
}
