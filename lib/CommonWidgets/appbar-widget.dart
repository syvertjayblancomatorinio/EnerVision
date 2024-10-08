import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

AppBar customAppBar1({
  String? title,
  VoidCallback? onBackPressed,
  bool showBackArrow = true,
  bool showTitle = true,
  bool showProfile = true,
  String? profileImage, // This should now be a URL
}) {
  return AppBar(
    toolbarHeight: 89,
    backgroundColor: Colors.white,
    leading: showBackArrow
        ? Padding(
            padding: const EdgeInsets.only(left: 20),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: 35,
                color: AppColors.primaryColor,
              ),
              onPressed: onBackPressed ?? () {},
            ),
          )
        : null,
    actions: showProfile
        ? [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                backgroundImage:
                    (profileImage != null && profileImage.isNotEmpty)
                        ? NetworkImage(profileImage!)
                        : const AssetImage('assets/profile (2).png')
                            as ImageProvider, // Default image
              ),
            ),
          ]
        : [],
    title: showTitle
        ? Container(
            width: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.primaryColor,
                  offset: Offset(1.0, 1.0),
                  blurRadius: 5.0,
                  spreadRadius: 1.0,
                ),
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(0.0, 0.0),
                  blurRadius: 0.0,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            height: 30,
            child: Center(
              child: Text(
                title ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          )
        : null,
    centerTitle: true,
  );
}
// AppBar customAppBar({
//   String? title,
//   VoidCallback? onBackPressed,
//   bool showBackArrow = true,
//   bool showTitle = true,
//   bool showProfile = true,
//   String? profileImage, // Make profileImage required
// }) {
//   return AppBar(
//     toolbarHeight: 89,
//     backgroundColor: Colors.white,
//     leading: showBackArrow
//         ? Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back,
//                 size: 35,
//                 color: AppColors.primaryColor,
//               ),
//               onPressed: onBackPressed ?? () {},
//             ),
//           )
//         : null,
//     actions: showProfile
//         ? [
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: CircleAvatar(
//                 backgroundImage: profileImage != null
//                     ? NetworkImage(profileImage)
//                     : AssetImage('assets/profile (2).png') as ImageProvider,
//               ),
//             ),
//           ]
//         : [],
//     title: showTitle
//         ? Container(
//             width: 250,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(15),
//               boxShadow: const [
//                 BoxShadow(
//                   color: AppColors.primaryColor,
//                   offset: Offset(1.0, 1.0),
//                   blurRadius: 5.0,
//                   spreadRadius: 1.0,
//                 ),
//                 BoxShadow(
//                   color: Colors.white,
//                   offset: Offset(0.0, 0.0),
//                   blurRadius: 0.0,
//                   spreadRadius: 0.0,
//                 ),
//               ],
//             ),
//             height: 30,
//             child: Center(
//               child: Text(
//                 title ?? '',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//             ),
//           )
//         : null,
//     centerTitle: true,
//   );
// }
