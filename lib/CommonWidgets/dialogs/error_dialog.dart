import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required List<String> messages,
  required String buttonText,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.secondaryColor,
                size: 50,
              ),
              const SizedBox(height: 20),
              const Text(
                'Appliance Already Exists',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 10),
              Text(
                'Oops! The appliance is already in your list. Please try again by adding a different appliance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontFamily: 'Montserrat'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  'Okay, Got it!',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: 'Montserrat'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
