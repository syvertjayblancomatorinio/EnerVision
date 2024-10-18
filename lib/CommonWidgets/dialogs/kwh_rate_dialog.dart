import 'package:flutter/material.dart';

Future<void> showKwhRateDialog(
    BuildContext context,
    TextEditingController kwhRateController,
    Function saveKwhRate,
    Function fetchAppliances,
    Function fetchDailyCost) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Enter kWh Rate'),
        content: TextField(
          controller: kwhRateController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter kWh rate'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              String kwhRate = kwhRateController.text;
              try {
                await saveKwhRate(kwhRate);
                Navigator.of(context).pop();
                fetchAppliances();
                fetchDailyCost();
              } catch (e) {
                print('Failed to save kWh rate: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
