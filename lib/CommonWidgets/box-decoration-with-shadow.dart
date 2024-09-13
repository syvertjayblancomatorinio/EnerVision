import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

import '../ConstantTexts/Theme.dart';

BoxDecoration reusableBoxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    boxShadow: const [
      BoxShadow(
        color: Color(0xFFADE7DB),
        // color: AppColors.primaryColor,
        offset: Offset(
          4,
          0,
        ),
        blurRadius: 4.0,
        spreadRadius: 4.0,
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(0.0, 0.0),
        blurRadius: 0.0,
        spreadRadius: 0.0,
      ),
    ],
  );
}

BoxDecoration greyBoxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    boxShadow: const [
      BoxShadow(
        color: Colors.grey,
        // color: AppColors.primaryColor,
        offset: Offset(
          0,
          0,
        ),
        blurRadius: 10.0,
        spreadRadius: 2.0,
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(0.0, 0.0),
        blurRadius: 0.0,
        spreadRadius: 0.0,
      ),
    ],
  );
}

InputDecoration buildInputDecoration(String labelText) {
  return InputDecoration(
    labelText: labelText,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15), // Set the border radius to 15
      borderSide: const BorderSide(color: AppColors.primaryColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15), // Set the border radius to 15
      borderSide: const BorderSide(color: AppColors.primaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15), // Set the border radius to 15
      borderSide: const BorderSide(color: AppColors.primaryColor),
    ),
  );
}
