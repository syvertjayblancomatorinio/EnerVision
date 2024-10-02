// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// class AppliancesPage extends StatefulWidget {
//   final String userId;
//
//   AppliancesPage({required this.userId});
//
//   @override
//   _AppliancesPageState createState() => _AppliancesPageState();
// }
//
// class _AppliancesPageState extends State<AppliancesPage> {
//   List<dynamic> appliances = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchAppliances();
//   }
//
//   Future<void> _fetchAppliances() async {
//     final url =
//         Uri.parse("http://10.0.2.2:8080/user/${widget.userId}/appliances");
//
//     var response = await http.get(url);
//
//     if (response.statusCode == 200) {
//       setState(() {
//         appliances = jsonDecode(response.body);
//       });
//     } else {
//       // Handle error
//       print('Failed to load appliances');
//     }
//   }
//
//   void showEditApplianceDialog(int index) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Edit Appliance'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               TextField(
//                 controller:
//                     TextEditingController(text: appliances[index]['name']),
//                 decoration: InputDecoration(labelText: 'Appliance Name'),
//               ),
//               // Add more fields as needed
//             ],
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Save'),
//               onPressed: () {
//                 // Implement save functionality
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Appliances'),
//       ),
//       body: ListView(
//         children: appliances.asMap().entries.map((entry) {
//           int index = entry.key;
//           var appliance = entry.value;
//           return Column(
//             children: [
//               ListTile(
//                 leading: Image.asset(
//                     appliance['imagePath'] ?? 'assets/dialogImage.png'),
//                 title: Text(appliance['applianceName'] ?? 'Unknown'),
//                 subtitle: Text(
//                     'Wattage: ${appliance['wattage'] ?? 'N/A'}\nUsage Pattern: ${appliance['usagePattern'] ?? 'N/A'}'),
//                 onTap: () => showEditApplianceDialog(index),
//               ),
//             ],
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
