import 'package:flutter/material.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/sign_up_page.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EnerVision',
      home: SignUpPage(),
    );
  }
}
