import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidgetWithAllMonths extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback getApplianceCount;

  const DatePickerWidgetWithAllMonths({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.getApplianceCount,
  });

  @override
  _DatePickerWidgetWithAllMonthsState createState() =>
      _DatePickerWidgetWithAllMonthsState();
}

class _DatePickerWidgetWithAllMonthsState
    extends State<DatePickerWidgetWithAllMonths> {
  late List<String> months;
  late List<int> years;

  String? selectedMonth;
  int? selectedYear;

  @override
  void initState() {
    super.initState();

    months = List.generate(
      12,
          (index) => DateFormat.MMMM().format(DateTime(0, index + 1)),
    );

    years = List.generate(10, (index) => DateTime.now().year - index);

    selectedMonth = DateFormat('MMMM').format(widget.initialDate);
    selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM yyyy').format(widget.initialDate);

    return GestureDetector(
      onTap: () => _showMonthYearPicker(context),
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

  Future<void> _showMonthYearPicker(BuildContext context) async {
    String tempSelectedMonth = selectedMonth!;
    int tempSelectedYear = selectedYear!;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            int monthIndex =
                                months.indexOf(tempSelectedMonth) + 1;

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
      },
    );
  }
}

class DatePickerWidget extends StatefulWidget {
  final DateTime initialDate;
  final void Function(DateTime) onDateSelected;
  final VoidCallback getApplianceCount;

  const DatePickerWidget({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
    required this.getApplianceCount,
  }) : super(key: key);

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  void _showDatePicker(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => CustomDatePicker(initialDate: selectedDate),
    );

    if (result != null && result['year'] != null && result['month'] != null) {
      final selectedYear = result['year'];
      final selectedMonth = result['month'];
      final int monthIndex = [
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
      ].indexOf(selectedMonth) +
          1;

      setState(() {
        selectedDate = DateTime(selectedYear, monthIndex);
      });

      widget.onDateSelected(selectedDate);
      widget.getApplianceCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM yyyy').format(selectedDate);

    return GestureDetector(
      onTap: () => _showDatePicker(context),
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
}

class CustomDatePicker extends StatefulWidget {
  final DateTime initialDate;

  const CustomDatePicker({
    Key? key,
    required this.initialDate,
  }) : super(key: key);

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late int selectedYear;
  String? selectedMonth;
  final List<String> months = [
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
    'December',
  ];

  // Get current year and month
  final int currentYear = DateTime.now().year;
  final int currentMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = months[widget.initialDate.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    if (selectedYear > 2024) {
                      setState(() {
                        selectedYear--;
                      });
                    }
                  },
                ),
                Text(
                  '$selectedYear',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon:
                  const Icon(Icons.arrow_forward_ios, color: Colors.black),
                  onPressed: () {
                    if (selectedYear < currentYear) {
                      setState(() {
                        selectedYear++;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: months.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 7.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 2.0,
              ),
              itemBuilder: (context, index) {
                final month = months[index];
                final isSelected = month == selectedMonth;

                // Disable months for the current year (after the current month)
                bool isDisabled = false;
                if (selectedYear == currentYear) {
                  // Disable current month (November) and months after it
                  if (index + 1 > currentMonth) {
                    isDisabled = true;
                  }
                }

                // Disable months in future years (2025 and beyond)
                if (selectedYear > currentYear) {
                  isDisabled = true;
                }

                // Disable the current month (November)
                if (selectedYear == currentYear &&
                    month == months[currentMonth - 1]) {
                  isDisabled = true;
                }

                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () => setState(() => selectedMonth = month),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1BBC9B)
                          : (isDisabled ? Colors.grey[300] : Colors.white),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      month,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: isSelected
                            ? Colors.white
                            : (isDisabled ? Colors.grey : Colors.black),
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'year': selectedYear,
                        'month': selectedMonth,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1BBC9B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
