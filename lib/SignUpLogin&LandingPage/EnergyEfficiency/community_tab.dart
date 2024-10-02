import 'package:flutter/material.dart';
import 'package:supabase_project/EnergyPage/MyEnergyDiary/appliances_container.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        SizedBox(height: 20),
        AppliancesContainer(),
      ],
    );
  }
}
