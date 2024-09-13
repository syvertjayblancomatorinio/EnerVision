import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/CommonWidgets/appliance-today-widgets.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/common-widgets.dart';

class ThisMonthPage extends StatefulWidget {
  @override
  _ThisMonthPageState createState() => _ThisMonthPageState();
}

class _ThisMonthPageState extends State<ThisMonthPage> {
  DateTime selectedDate = DateTime.now();
  late String formattedDate;
  double totalKWhPerDay = 0.0;

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('MMMM yyyy').format(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),

        //DatePickerWidget
        DatePickerWidget(
          initialDate: selectedDate,
          onDateSelected: (date) {
            setState(() {
              selectedDate = date;
              formattedDate = DateFormat('MMMM yyyy').format(selectedDate);
            });
          },
        ),
        Row(
          children: [
            CostKilowatt(totalKWhPerDay, 'cost'),
            CostKilowatt(10.1, 'kw'),
          ],
        ),
        const HomeUsage(),
        // const SizedBox(height: 70),
        // const Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [Appliances(), Appliances(), Appliances()],
        // ),
      ],
    );
  }
}
