import 'package:flutter/material.dart';
import 'package:supabase_project/SignUpLogin&LandingPage/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  // Ensure that widgets are initialized before using any Hive functionality
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Open your boxes (if needed)
  var box = await Hive.openBox('myBox'); // Example box

  // Run your app
  runApp(MyApp());
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
