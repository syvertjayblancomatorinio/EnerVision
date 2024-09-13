import 'package:flutter/material.dart';
import 'package:supabase_project/SignUP/sign_up_page.dart';
import 'package:supabase_project/SignUP/sign_up_page2.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EnerVision',
      home: SignUpPage(),
    );
  }
}
