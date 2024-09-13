import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import '../../CommonWidgets/box-decoration-with-shadow.dart';
import '../../ConstantTexts/Theme.dart';

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

class HomeUsage extends StatelessWidget {
  const HomeUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      width: 182,
      decoration: greyBoxDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.home_max_outlined,
            size: 100,
          ),
          Text(
            '13.34 kwh',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Home Usage',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

class NumberOfAppliances extends StatelessWidget {
  const NumberOfAppliances({super.key});

  @override
  Widget build(BuildContext context) {
    int numberOfAppliances = 10;

    return Container(
      height: 170,
      width: 113,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: greyBoxDecoration(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone_android_outlined,
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                "$numberOfAppliances",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "No. of Appliances Added",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// date_picker_widget.dart

class DatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const DatePickerWidget({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTime selectedDate;
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    formattedDate = DateFormat('MMMM yyyy').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0, bottom: 10),
      child: GestureDetector(
        onTap: () async {
          final DateTime? dateTime = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(3000),
          );
          if (dateTime != null) {
            setState(() {
              selectedDate = dateTime;
              formattedDate = DateFormat('MMMM yyyy').format(selectedDate);
            });
            widget.onDateSelected(dateTime);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                formattedDate,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(
              Icons.calendar_month,
              size: 30,
              color: Color(0xFF02A676),
            ),
          ],
        ),
      ),
    );
  }
}

//
// Widget lastDescription(
//     BuildContext context, String imagePath, String text1, String text2) {
//   return Container(
//     margin: const EdgeInsets.all(20),
//     child: Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Image.asset(
//               imagePath,
//               width: 120,
//             ),
//           ],
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Text(
//               text1,
//               style: Theme.of(context).textTheme.bodyText2?.copyWith(
//                   fontSize: 10), // Adjusting text style to match theme
//             ),
//           ),
//         )
//       ],
//     ),
//   );
// }
