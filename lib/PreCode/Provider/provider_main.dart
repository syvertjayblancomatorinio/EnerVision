import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_project/PreCode/Provider/ApplianceProvider.dart';

import '../../CommonWidgets/bottom-navigation-bar.dart';

void main() {
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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BottomNavigation(selectedIndex: 0),
    );
  }
}
