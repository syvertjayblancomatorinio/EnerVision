// import 'dart:convert';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_project/Buttons/buttons_widget.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:supabase_project/CommonWidgets/dialogs/add_appliance_dialog.dart';
// import 'package:supabase_project/CommonWidgets/appbar-widget.dart';
// import 'package:supabase_project/CommonWidgets/bottom-navigation-bar.dart';
// import 'package:supabase_project/CommonWidgets/dialogs/edit_appliance_dialog.dart';
// import 'package:supabase_project/EnergyPage/MyEnergyDiary/appliance-widgets/appliance-tile-widget.dart';
// import 'package:supabase_project/SignUP/user.dart';
//
// import '../../../ConstantTexts/Theme.dart';
//
// const Duration kFakeHttpRequestDuration = Duration(seconds: 3);
//
// class AppliancesPage1 extends StatefulWidget {
//   final String userId;
//   const AppliancesPage1({super.key, required this.userId});
//
//   @override
//   _AppliancesPage1State createState() => _AppliancesPage1State();
// }
//
// class _AppliancesPage1State extends State<AppliancesPage1> {
//   TextEditingController editApplianceNameController = TextEditingController();
//   TextEditingController editWattageController = TextEditingController();
//   TextEditingController editUsagePatternController = TextEditingController();
//
//   final addApplianceNameController = TextEditingController();
//   final addWattageController = TextEditingController();
//   final addUsagePatternController = TextEditingController();
//   late final TextEditingController controller;
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   List<dynamic> appliances = [];
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAppliances();
//     editUsagePatternController.addListener(() {
//       String text = editUsagePatternController.text;
//       double? value = double.tryParse(text);
//       if (value != null && value > 24) {
//         // Ensure update does not cause an infinite loop
//         editUsagePatternController.value = TextEditingValue(
//           text: '24',
//           selection: TextSelection.fromPosition(
//             const TextPosition(offset: '24'.length),
//           ),
//         );
//       }
//     });
//
//     addUsagePatternController.addListener(() {
//       String text = addUsagePatternController.text;
//       double? value = double.tryParse(text);
//       if (value != null && value > 24) {
//         addUsagePatternController.value = TextEditingValue(
//           text: '24',
//           selection: TextSelection.fromPosition(
//             const TextPosition(offset: '24'.length),
//           ),
//         );
//       }
//     });
//   }
//
//   Future<void> deleteAppliance(String applianceId) async {
//     final url = Uri.parse('http://10.0.2.2:8080/deleteAppliance/$applianceId');
//     final response = await http.delete(
//       url,
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//     );
//     if (response.statusCode == 200) {
//       print('Appliance deleted successfully');
//     } else {
//       print('Failed to delete appliance: ${response.body}');
//     }
//   }
//
//   void _showActionSheet(BuildContext context, int index) {
//     final appliance = appliances[index];
//
//     showCupertinoModalPopup(
//       context: context,
//       builder: (BuildContext context) => CupertinoActionSheet(
//         title: const Text('Appliance Actions'),
//         actions: <CupertinoActionSheetAction>[
//           CupertinoActionSheetAction(
//             onPressed: () {
//               Navigator.pop(context); // Close the action sheet
//               openEditApplianceDialog(index); // Open edit dialog
//             },
//             child: const Text('Edit Appliance'),
//           ),
//           CupertinoActionSheetAction(
//             isDestructiveAction: true,
//             onPressed: () {
//               Navigator.pop(context); // Close the action sheet
//               _confirmDeleteAppliance(index); // Delete appliance
//             },
//             child: const Text('Delete Appliance'),
//           ),
//         ],
//         cancelButton: CupertinoActionSheetAction(
//           onPressed: () {
//             Navigator.pop(context); // Close the action sheet
//           },
//           child: const Text('Cancel'),
//         ),
//       ),
//     );
//   }
//
//   void _confirmDeleteAppliance(int index) {
//     final appliance = appliances[index];
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Center(child: Text('Delete Appliance?')),
//           content: const Padding(
//             padding: EdgeInsets.all(10.0),
//             child: Text('Are you sure you want to delete this appliance?'
//                 ' This cannot be undone.'),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteAppliance(appliance['_id']).then((_) {
//                   fetchAppliances(); // Refresh appliance list
//                   Navigator.of(context).pop();
//                 });
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> fetchAppliances() async {
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
//       print('Failed to load appliances');
//     }
//   }
//
//   Future<void> addToMonthlyConsumption() async {
//     final url = Uri.parse("http://10.0.2.2:8080/save-consumption");
//
//     var response = await http.post(
//       url,
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, dynamic>{
//         'userId': widget.userId,
//         'applianceId': controller.text,
//         'usage': controller.text,
//       }),
//     );
//
//     if (response.statusCode == 201) {
//       print('Monthly consumption added successfully');
//       // Fetch updated appliances after adding a new consumption
//       fetchAppliances();
//     } else {
//       print('Failed to add monthly consumption: ${response.body}');
//     }
//   }
//
//   Future<void> addAppliance() async {
//     final url = Uri.parse("http://10.0.2.2:8080/addApplianceToUser");
//
//     var response = await http.post(
//       url,
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, dynamic>{
//         'userId': widget.userId, // Include userId in the request
//         'applianceData': {
//           'applianceName': addApplianceNameController.text,
//           'wattage': addWattageController.text,
//           'usagePattern': addUsagePatternController.text
//         }
//       }),
//     );
//
//     if (response.statusCode == 201) {
//       print('Appliance added successfully');
//       // Fetch updated appliances after adding a new one
//       addToMonthlyConsumption();
//       fetchAppliances();
//     } else {
//       print('Failed to add appliance: ${response.body}');
//     }
//   }
//
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Center(child: Text(message)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//
//   Future<void> updateAppliance(
//       String applianceId, Map<String, dynamic> updates) async {
//     final url = Uri.parse('http://10.0.2.2:8080/appliance/$applianceId');
//
//     final response = await http.patch(
//       url,
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(updates),
//     );
//
//     if (response.statusCode == 200) {
//       final responseBody = jsonDecode(response.body);
//       _showSnackBar('Update Success');
//     } else {
//       // Handle error response
//       final responseBody = jsonDecode(response.body);
//       _showSnackBar('Failed to update appliance: ${responseBody['message']}');
//     }
//   }
//
//   // void showAddApplianceDialog() {
//   //   addApplianceNameController.clear();
//   //   addWattageController.clear();
//   //   addUsagePatternController.clear();
//   //
//   //   showDialog(
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       return Dialog(
//   //         child: Stack(
//   //           clipBehavior: Clip.none,
//   //           alignment: Alignment.topCenter,
//   //           children: [
//   //             Expanded(
//   //               child: Container(
//   //                 padding: const EdgeInsets.all(30),
//   //                 decoration: BoxDecoration(
//   //                   borderRadius: BorderRadius.circular(40),
//   //                   color: Colors.white,
//   //                 ),
//   //                 child: Form(
//   //                   key: formKey,
//   //                   child: Column(
//   //                     mainAxisSize: MainAxisSize.min,
//   //                     children: [
//   //                       const SizedBox(height: 40),
//   //                       const Text('Add Appliance To Track',
//   //                           style: TextStyle(
//   //                               fontSize: 18, fontWeight: FontWeight.bold)),
//   //                       const SizedBox(height: 20),
//   //                       TextFormField(
//   //                         controller: addApplianceNameController,
//   //                         decoration: InputDecoration(
//   //                           labelText: 'Appliance Name',
//   //                           border: OutlineInputBorder(
//   //                             borderRadius: BorderRadius.circular(20),
//   //                           ),
//   //                         ),
//   //                         validator: (value) {
//   //                           if (value == null || value.isEmpty) {
//   //                             return 'Please enter an appliance name';
//   //                           }
//   //                           return null;
//   //                         },
//   //                       ),
//   //                       const SizedBox(height: 10),
//   //                       TextFormField(
//   //                         controller: addWattageController,
//   //                         keyboardType: TextInputType.number,
//   //                         decoration: InputDecoration(
//   //                           labelText: 'Wattage',
//   //                           border: OutlineInputBorder(
//   //                             borderRadius: BorderRadius.circular(15),
//   //                           ),
//   //                         ),
//   //                         validator: (value) {
//   //                           if (value == null || value.isEmpty) {
//   //                             return 'Please enter the wattage';
//   //                           }
//   //                           if (double.tryParse(value) == null) {
//   //                             return 'Please enter a valid number';
//   //                           }
//   //                           return null;
//   //                         },
//   //                       ),
//   //                       const SizedBox(height: 10),
//   //                       TextFormField(
//   //                         controller: addUsagePatternController,
//   //                         keyboardType: TextInputType.number,
//   //                         decoration: InputDecoration(
//   //                           labelText: 'Usage Pattern (hours per day)',
//   //                           border: OutlineInputBorder(
//   //                             borderRadius: BorderRadius.circular(15),
//   //                           ),
//   //                         ),
//   //                         onChanged: (value) {
//   //                           final doubleValue = double.tryParse(value);
//   //                           if (doubleValue != null) {
//   //                             if (doubleValue > 24) {
//   //                               addUsagePatternController.text = '24';
//   //                               addUsagePatternController.selection =
//   //                                   TextSelection.fromPosition(
//   //                                 TextPosition(offset: '24'.length),
//   //                               );
//   //                             }
//   //                           } else {
//   //                             print('Invalid value');
//   //                           }
//   //                         },
//   //                         validator: (value) {
//   //                           // No validation message for exceeding 24 hours
//   //                           if (value == null || value.isEmpty) {
//   //                             return 'Please enter the usage pattern';
//   //                           }
//   //                           return null;
//   //                         },
//   //                       ),
//   //                       const SizedBox(height: 20),
//   //                       Row(
//   //                         mainAxisAlignment: MainAxisAlignment.end,
//   //                         children: [
//   //                           TextButton(
//   //                             onPressed: () {
//   //                               Navigator.of(context).pop();
//   //                             },
//   //                             child: const Text('Cancel'),
//   //                           ),
//   //                           const SizedBox(width: 10),
//   //                           ElevatedButton(
//   //                             onPressed: () {
//   //                               if (formKey.currentState!.validate()) {
//   //                                 // Add appliance logic here
//   //                                 addAppliance();
//   //                                 Navigator.of(context).pop();
//   //                               }
//   //                             },
//   //                             child: const Text('Add'),
//   //                           ),
//   //                         ],
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //             Positioned(
//   //               top: -70.0,
//   //               child: Container(
//   //                 decoration: BoxDecoration(
//   //                   borderRadius: BorderRadius.circular(100),
//   //                   color: Colors.white,
//   //                 ),
//   //                 width: 140,
//   //                 height: 140,
//   //                 child: ClipRRect(
//   //                   borderRadius: BorderRadius.circular(100),
//   //                   child: Image.asset('assets/dialogImage.png',
//   //                       fit: BoxFit.cover),
//   //                 ),
//   //               ),
//   //             ),
//   //           ],
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
//   void showAddApplianceDialog(
//       BuildContext context,
//       TextEditingController addApplianceNameController,
//       TextEditingController addWattageController,
//       TextEditingController addUsagePatternController,
//       GlobalKey<FormState> formKey,
//       VoidCallback addAppliance) {
//     addApplianceNameController.clear();
//     addWattageController.clear();
//     addUsagePatternController.clear();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AddApplianceDialog(
//           addApplianceNameController: addApplianceNameController,
//           addWattageController: addWattageController,
//           addUsagePatternController: addUsagePatternController,
//           formKey: formKey,
//           addAppliance: addAppliance,
//         );
//       },
//     );
//   }
//
//   void openEditApplianceDialog(int index) {
//     var appliance = appliances[index];
//
//     editApplianceNameController.text = appliance['name'] ?? '';
//     editWattageController.text = appliance['wattage']?.toString() ?? '';
//     editUsagePatternController.text =
//         appliance['usagePattern']?.toString() ?? '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return EditApplianceDialog(
//           editApplianceNameController: editApplianceNameController,
//           editWattageController: editWattageController,
//           editUsagePatternController: editUsagePatternController,
//           formKey: formKey,
//           editAppliance: () {}, // You can define custom actions here if needed
//           appliance: appliance,
//           updateAppliance: updateAppliance,
//           fetchAppliances: fetchAppliances,
//         );
//       },
//     );
//   }
//
//   void showEditApplianceDialog(int index) {
//     final appliance = appliances[index]; // Get the appliance to edit
//
//     // Populate controllers with existing data
//     editApplianceNameController.text = appliance['applianceName'] ?? '';
//     editWattageController.text = appliance['wattage'].toString() ?? '';
//     editUsagePatternController.text =
//         appliance['usagePattern'].toString() ?? '';
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           contentPadding: const EdgeInsets.symmetric(horizontal: 20),
//           content: SingleChildScrollView(
//             child: SizedBox(
//               width: 800,
//               child: Form(
//                 key: formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Image.asset('assets/dialogImage.png',
//                         height: 100, width: 100),
//                     const SizedBox(height: 20),
//                     Text(
//                       'Current Added Appliance: ',
//                       style: Theme.of(context).textTheme.titleMedium,
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: editApplianceNameController,
//                       decoration: InputDecoration(
//                         labelText: 'Enter New Appliance Name',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter an appliance name';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 10),
//                     TextFormField(
//                       controller: editWattageController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: 'Wattage',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter the wattage';
//                         }
//                         if (double.tryParse(value) == null) {
//                           return 'Please enter a valid number';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 10),
//                     TextFormField(
//                       controller: editUsagePatternController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: 'Usage Pattern (hours per day)',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter the usage pattern';
//                         }
//                         if (double.tryParse(value) == null) {
//                           return 'Please enter a valid number';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 _showSnackBar('Appliance was not Updated');
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (formKey.currentState!.validate()) {
//                   final updatedAppliance = {
//                     'applianceName': editApplianceNameController.text,
//                     'wattage': double.parse(editWattageController.text),
//                     'usagePattern':
//                         double.parse(editUsagePatternController.text),
//                   };
//
//                   updateAppliance(appliance['_id'], updatedAppliance).then((_) {
//                     fetchAppliances(); // Refresh appliance list
//                     Navigator.of(context).pop();
//                   });
//                 }
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: AppTheme.getAppTheme(),
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         bottomNavigationBar: const BottomNavigation(selectedIndex: 1),
//         appBar: customAppBar1(
//             title: 'My Appliances', showBackArrow: false, showProfile: false),
//         body: content(),
//       ),
//     );
//   }
//
//   Widget content() {
//     return Column(
//       children: [
//         Expanded(
//           child: ListView(
//             children: appliances.asMap().entries.map((entry) {
//               int index = entry.key;
//               var appliance = entry.value;
//               return Container(
//                 margin:
//                     const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8.0),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: ListTile(
//                   leading: ClipRRect(
//                     borderRadius: BorderRadius.circular(50),
//                     child: Image.asset(
//                       appliance['imagePath'] ?? 'assets/dialogImage.png',
//                       height: 50,
//                       width: 50,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   title: Text(
//                     appliance['applianceName'] ?? 'Unknown',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   subtitle: Text(
//                     'Wattage: ${appliance['wattage'] ?? 'N/A'} watts\nUsage Pattern: ${appliance['usagePattern'] ?? 'N/A'} hours per day',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   trailing: CupertinoButton(
//                     padding: EdgeInsets.zero,
//                     onPressed: () => _showActionSheet(context, index),
//                     child: const Icon(Icons.more_vert),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40),
//           child: Center(
//             child: ElevatedButton.icon(
//               onPressed: () => showAddApplianceDialog(
//                 context,
//                 addApplianceNameController,
//                 addWattageController,
//                 addUsagePatternController,
//                 formKey,
//                 addAppliance,
//               ),
//               icon: const Icon(Icons.add, size: 0),
//               label: const Text('Add Appliance'),
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                 ),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16.0),
//       ],
//     );
//   }
// }
