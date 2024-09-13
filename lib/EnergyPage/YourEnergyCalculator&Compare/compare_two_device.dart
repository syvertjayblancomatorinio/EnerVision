import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
import 'package:supabase_project/CommonWidgets/box-decoration-with-shadow.dart';
import 'package:supabase_project/ConstantTexts/Theme.dart';
import 'package:supabase_project/MockData/data/appliances.dart';

class CompareTwoDevices extends StatelessWidget {
  const CompareTwoDevices({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getAppTheme(),
      home: Scaffold(
        appBar: customAppBar1(
          title: 'Compare Device',
          showBackArrow: true,
          showProfile: false,
          onBackPressed: () {
            Navigator.pop(context);
          },
        ),
        body: content(
          context,
        ),
      ),
    );
  }
}

Widget content(BuildContext context) {
  return Container(
    decoration: greyBoxDecoration(),
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            content1(
                context, mockAppliances[1]['name'], mockAppliances[0]['name']),
          ],
        ),
      ),
    ),
  );
}

Widget content1(BuildContext context, String appliance1, String appliance2) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      Container(
        height: 70,
        width: 153,
        decoration: greyBoxDecoration(),
        alignment: Alignment.center,
        child: Text(
          appliance1,
          textAlign: TextAlign.center,
        ),
      ),
      Container(
          height: 70,
          width: 153,
          alignment: Alignment.center,
          decoration: greyBoxDecoration(),
          child: Text(
            appliance2,
            textAlign: TextAlign.center,
          )),
    ],
  );
}
