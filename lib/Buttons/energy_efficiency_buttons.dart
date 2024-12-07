import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/AuthService/base_url.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

import '../AuthService/models/user_model.dart';
import '../all_imports/imports.dart';


class YourEnergyButtons extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSegmentTapped;

  YourEnergyButtons({
    required this.selectedIndex,
    required this.onSegmentTapped,
  });

  @override
  _YourEnergyButtonsState createState() => _YourEnergyButtonsState();
}

class _YourEnergyButtonsState extends State<YourEnergyButtons> {
  final List<String> _segments = ["Your Energy", "Community"];
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

// COMMUNITY GUIDELINES CHECKING
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  void _handleCommunityButtonTap(int index) async {
    try {
      final accepted = await _checkCommunityGuidelinesAccepted();
      if (accepted) {
        widget.onSegmentTapped(1);
      } else {
        widget.onSegmentTapped(2);
      }
    } catch (_) {
      _showErrorSnackBar('An error occurred while processing your request.');
    }
  }

  Future<bool> _checkCommunityGuidelinesAccepted() async {
    final box = Hive.box<User>('userBox');
    final currentUser = box.get('currentUser');

    if (currentUser!.userId == null) {
      _showErrorSnackBar('User ID not found.');
      return false;
    }

    try {
      final url = '${ApiConfig.baseUrl}/getCommunityGuidelines/${currentUser.userId}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['accepted'] ?? false;
      } else {
        throw Exception(
            'Failed to fetch status. Error: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('Error checking guidelines: $e');
      return false;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
//

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      decoration: reusableBoxDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_segments.length, (index) {
          bool isSelected = widget.selectedIndex == index;
          return GestureDetector(
            onTap: () {
              if (index == 1) {
                _handleCommunityButtonTap(index);
              } else {
                widget.onSegmentTapped(index);
              }
            },
            child: Container(
              padding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(
                _segments[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class EnergyDiaryButtons extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSegmentTapped;

  EnergyDiaryButtons({
    required this.selectedIndex,
    required this.onSegmentTapped,
  });

  @override
  _EnergyDiaryButtonsState createState() => _EnergyDiaryButtonsState();
}

class _EnergyDiaryButtonsState extends State<EnergyDiaryButtons> {
  final List<String> _segments = ["Last Month", "Today", "This Month"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      decoration: reusableBoxDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_segments.length, (index) {
          bool isSelected = widget.selectedIndex == index;
          return GestureDetector(
            onTap: () {
              widget.onSegmentTapped(index);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(
                _segments[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/*

class YourEnergyButtons extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSegmentTapped;

  YourEnergyButtons({
    required this.selectedIndex,
    required this.onSegmentTapped,
  });

  @override
  _YourEnergyButtonsState createState() => _YourEnergyButtonsState();
}

class _YourEnergyButtonsState extends State<YourEnergyButtons> {
  final List<String> _segments = ["Your Energy", "Community"];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      decoration: reusableBoxDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_segments.length, (index) {
          bool isSelected = widget.selectedIndex == index;
          return GestureDetector(
            onTap: () {
              widget.onSegmentTapped(index);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(
                _segments[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}


 */