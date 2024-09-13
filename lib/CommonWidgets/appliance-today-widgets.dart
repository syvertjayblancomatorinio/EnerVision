import 'package:flutter/material.dart';
import '../CommonWidgets/box-decoration-with-shadow.dart';

Widget CostKilowatt(double dailyCost, String cost) {
  return Container(
    height: 70,
    width: 153,
    decoration: greyBoxDecoration(),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dailyCost.toStringAsFixed(
                2), // Convert double to string with 2 decimal places
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            cost,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}
