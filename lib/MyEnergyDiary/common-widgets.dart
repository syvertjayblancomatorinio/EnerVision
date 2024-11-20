import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../CommonWidgets/box_decorations.dart';

class HomeUsage extends StatelessWidget {
  final String kwh;

  const HomeUsage({super.key, required this.kwh});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 208,
      width: 202,
      decoration: greyBoxDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.house_siding_rounded,
            size: 150,
          ),
          Text(
            kwh,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Home Usage',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

class DatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback getApplianceCount;

  const DatePickerWidget({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.getApplianceCount,
  });

  @override
  _DatePickerWidgetState createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late List<String> months;
  late List<int> years;

  String? selectedMonth;
  int? selectedYear;

  @override
  void initState() {
    super.initState();

    int currentMonthIndex = DateTime.now().month;
    months = List.generate(currentMonthIndex - 1,
        (index) => DateFormat.MMMM().format(DateTime(0, index + 1)));

    years = List.generate(01, (index) => DateTime.now().year - index);

    selectedMonth = DateFormat('MMMM').format(widget.initialDate);
    selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM yyyy').format(widget.initialDate);

    return GestureDetector(
      onTap: () => _showApplianceErrorDialog(context),
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                formattedDate,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.calendar_month, size: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _showApplianceErrorDialog(BuildContext context) async {
    await showDatePicker(context: context);
  }

  Future<Object?> showDatePicker({
    required BuildContext context,
  }) async {
    String tempSelectedMonth = selectedMonth!;
    int tempSelectedYear = selectedYear!;
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
      transitionBuilder: (context, animation1, animation2, child) {
        return Transform.scale(
          scale: animation1.value,
          child: Opacity(
            opacity: animation1.value,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation1, animation2) {
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
                  'SELECT MONTH AND YEAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DropdownButton<String>(
                      value: tempSelectedMonth,
                      onChanged: (String? newMonth) {
                        if (newMonth != null) {
                          setState(() {
                            tempSelectedMonth = newMonth;
                          });
                        }
                      },
                      items: months.map((String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                    ),
                    DropdownButton<int>(
                      value: tempSelectedYear,
                      onChanged: (int? newYear) {
                        if (newYear != null) {
                          setState(() {
                            tempSelectedYear = newYear;
                          });
                        }
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
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        int monthIndex = months.indexOf(tempSelectedMonth) + 1;

                        DateTime newDate =
                            DateTime(tempSelectedYear, monthIndex);

                        widget.onDateSelected(newDate);
                        widget.getApplianceCount();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image (7).png',
                width: 150.0,
                height: 50.0,
                fit: BoxFit.contain,
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

class EstimatedCostPerMonth extends StatelessWidget {
  const EstimatedCostPerMonth({super.key});

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
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image (9).png',
                width: 150.0,
                height: 50.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10.0),
              Text(
                "$numberOfAppliances",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Estimated Cost for the Month",
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

class PeakUsageTime extends StatelessWidget {
  const PeakUsageTime({super.key});

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
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/image (8).png',
                width: 150.0,
                height: 50.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10.0),
              Text(
                "$numberOfAppliances",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Peak Usage Time",
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

class ApplianceInfoCard extends StatelessWidget {
  final String imagePath;
  final String mainText;
  final String subText;

  const ApplianceInfoCard({
    super.key,
    required this.imagePath,
    required this.mainText,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      width: 113,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: greyBoxDecoration(), // Assuming this is defined elsewhere
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 150.0,
                height: 50.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10.0),
              Text(
                mainText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  subText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
