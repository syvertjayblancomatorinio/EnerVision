import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'SignUpLogin&LandingPage/sign_up_page.dart';
import 'AuthService/models/user_model.dart';
import 'PreCode/Provider/ApplianceProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('userBox');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApplianceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EnerVision',
      home: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child:  SignUpPage(),
      ),
    );
  }
}



