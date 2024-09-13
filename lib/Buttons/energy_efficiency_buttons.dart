import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/box-decoration-with-shadow.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

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
