import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_project/EnergyEfficiency/Community/community_tab.dart';
import 'package:supabase_project/EnergyEfficiency/Community/create_post.dart';
import 'package:supabase_project/EnergyEfficiency/Community/energy_effieciency_page.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/login_page.dart';
import 'package:supabase_project/StaticPages/aircon.dart';
import 'package:supabase_project/MainFolder/secondary_compare.dart';
import 'dart:async';

import 'package:supabase_project/StaticPages/anne_aircon.dart';

Future<void> main() async {
  runApp(
    const MaterialApp(
      home: CarmelAndAnne(selectedIndex: 1),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      body: const Center(
        child: Text("Welcome to Enervision!"),
      ),
    );
  }
}

// Example home screen after splash screen

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
