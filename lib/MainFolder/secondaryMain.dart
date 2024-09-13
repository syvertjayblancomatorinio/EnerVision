import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_project/Login/setup_profile.dart';

import '../EnergyPage/MyEnergyDiary/my_energy_diary_page.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        home: Scaffold(
            appBar: AppBar(),
            body: Container(
              child: Row(
                children: [
                  Container(
                    width: 100,
                    color: Colors.blue,
                  ),
                  Container(
                    width: 100,
                    color: Colors.red,
                  ),
                  Container(
                    width: 100,
                    color: Colors.purpleAccent,
                  ),
                  Positioned(
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            )));
  }
}
