import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import '../../CommonWidgets/box_decorations.dart';
import '../../ConstantTexts/Theme.dart';



class HomeUsage extends StatelessWidget {
  const HomeUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 208,
      width: 202,
      decoration: greyBoxDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.house_siding_rounded,
            size: 150,
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
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  List<int> years = List.generate(
      101, (index) => 2023 + index); // For years from 2023 onwards
  late String selectedMonth;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    selectedMonth = DateFormat('MMMM').format(selectedDate);
    selectedYear = selectedDate.year;
    formattedDate = DateFormat('MMMM yyyy').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'SELECT MONTH',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedMonth,
                  onChanged: (String? newMonth) {
                    setState(() {
                      selectedMonth = newMonth!;
                      selectedDate = DateTime(
                        selectedYear,
                        months.indexOf(selectedMonth) + 1,
                      );
                    });
                  },
                  items: months.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }).toList(),
                ),
                DropdownButton<int>(
                  value: selectedYear,
                  onChanged: (int? newYear) {
                    setState(() {
                      selectedYear = newYear!;
                      selectedDate = DateTime(
                        selectedYear,
                        months.indexOf(selectedMonth) + 1,
                      );
                    });
                  },
                  items: years.map((int year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onDateSelected(selectedDate);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class DatePickerWidget extends StatefulWidget {
//   final DateTime initialDate;
//   final ValueChanged<DateTime> onDateSelected;
//
//   const DatePickerWidget({
//     super.key,
//     required this.initialDate,
//     required this.onDateSelected,
//   });
//
//   @override
//   _DatePickerWidgetState createState() => _DatePickerWidgetState();
// }
//
// class _DatePickerWidgetState extends State<DatePickerWidget> {
//   late DateTime selectedDate;
//   late String formattedDate;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedDate = widget.initialDate;
//     formattedDate = DateFormat('MMMM yyyy').format(selectedDate);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 40.0, bottom: 10),
//       child: GestureDetector(
//         onTap: () async {
//           final DateTime? dateTime = await showDatePicker(
//             context: context,
//             initialDate: selectedDate,
//             firstDate: DateTime(2000),
//             lastDate: DateTime(3000),
//           );
//           if (dateTime != null) {
//             setState(() {
//               selectedDate = dateTime;
//               formattedDate = DateFormat('MMMM yyyy').format(selectedDate);
//             });
//             widget.onDateSelected(dateTime);
//           }
//         },
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.only(top: 5.0),
//               child: Text(
//                 formattedDate,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 5),
//             const Icon(
//               Icons.calendar_month,
//               size: 30,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//
// Widget lastDescription(
//     BuildContext context, String imagePath, String class _DatePickerWidgetState extends State<DatePickerWidget> {
//   late DateTime selectedDate;
//   late String formattedDate;
//   List<String> months = [
//     'January', 'February', 'March', 'April', 'May', 'June',
//     'July', 'August', 'September', 'October', 'November', 'December'
//   ];
//   List<int> years = List.generate(101, (index) => 2023 - index); // For years from 2023 back to 1923
//   late String selectedMonth;
//   late int selectedYear;
//
//   @override
//   void initState() {
//     super.initState();
//     selectedDate = widget.initialDate;
//     selectedMonth = DateFormat('MMMM').format(selectedDate);
//     selectedYear = selectedDate.year;
//     formattedDate = DateFormat('MMMM yyyy').format(selectedDate);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'SELECT MONTH',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 DropdownButton<String>(
//                   value: selectedMonth,
//                   onChanged: (String? newMonth) {
//                     setState(() {
//                       selectedMonth = newMonth!;
//                       selectedDate = DateTime(
//                         selectedYear,
//                         months.indexOf(selectedMonth) + 1,
//                       );
//                     });
//                   },
//                   items: months.map((String month) {
//                     return DropdownMenuItem<String>(
//                       value: month,
//                       child: Text(month),
//                     );
//                   }).toList(),
//                 ),
//                 DropdownButton<int>(
//                   value: selectedYear,
//                   onChanged: (int? newYear) {
//                     setState(() {
//                       selectedYear = newYear!;
//                       selectedDate = DateTime(
//                         selectedYear,
//                         months.indexOf(selectedMonth) + 1,
//                       );
//                     });
//                   },
//                   items: years.map((int year) {
//                     return DropdownMenuItem<int>(
//                       value: year,
//                       child: Text(year.toString()),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.white,
//                     side: const BorderSide(color: Colors.grey),
//                   ),
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(color: Colors.black),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     widget.onDateSelected(selectedDate);
//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.teal,
//                   ),
//                   child: const Text('Save'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }text1, String text2) {
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
