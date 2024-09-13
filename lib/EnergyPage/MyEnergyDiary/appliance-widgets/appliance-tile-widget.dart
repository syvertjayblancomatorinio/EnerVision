import 'package:flutter/material.dart';
import '../appliance-widgets/calculator.dart';

late EnergyCalculator energyCalculator;

Widget Appliance(
  String imagePath,
  String applianceName,
  double wattage,
  int usagePattern,
  VoidCallback onEdit,
) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    padding: const EdgeInsets.symmetric(vertical: 12.0),
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
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              imagePath,
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  applianceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Wattage: ${wattage.toStringAsFixed(0)} watts',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Usage Pattern: $usagePattern hours per day',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(
            Icons.edit,
            color: Colors.blue,
          ),
          onPressed: onEdit,
        ),
      ],
    ),
  );
}
