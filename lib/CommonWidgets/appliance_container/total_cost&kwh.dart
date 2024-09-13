import 'package:flutter/material.dart';
import 'package:supabase_project/CommonWidgets/box-decoration-with-shadow.dart';

class TotalCostDisplay extends StatelessWidget {
  final String cost;

  const TotalCostDisplay({Key? key, required this.cost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 153,
      decoration: greyBoxDecoration(),
      child: Center(
        child: Text(
          cost,
        ),
      ),
    );
  }
}
