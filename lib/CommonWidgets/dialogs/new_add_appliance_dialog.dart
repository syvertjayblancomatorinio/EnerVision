import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:supabase_project/all_imports/imports.dart';

import '../../ConstantTexts/final_texts.dart';
import '../../PreCode/Provider/ApplianceProvider.dart';

class AddApplianceDialog extends StatefulWidget {
  final TextEditingController addApplianceNameController;
  final TextEditingController addWattageController;
  final TextEditingController addUsagePatternController;
  final TextEditingController addApplianceCategoryController;
  final GlobalKey<FormState> formKey;
  final Function(List<int>) addAppliance;
  // final Function(List<int>) addAppliance;
  const AddApplianceDialog({
    super.key,
    required this.addApplianceNameController,
    required this.addWattageController,
    required this.addUsagePatternController,
    required this.formKey,
    required this.addAppliance,
    required this.addApplianceCategoryController,
  });

  @override
  State<AddApplianceDialog> createState() => _AddApplianceDialogState();
}

class _AddApplianceDialogState extends State<AddApplianceDialog> {
  List<int> selectedDays = [];
  final AppControllers controller = AppControllers();
  bool isAllSelected = false;

  @override
  void initState() {
    super.initState();
    widget.addApplianceCategoryController.text = 'Personal Devices';
    _initializeSelectedDays();
  }

  void _initializeSelectedDays() {
    final now = DateTime.now();
    final localNow = now.toLocal();
    // print('UTC Time: $now');
    // print('Local Time: $localNow');
    // print('Time Zone Offset: ${localNow.timeZoneOffset}');

    final currentDay = localNow.weekday % 7;
    setState(() {
      selectedDays = [currentDay + 1];
    });
  }


  void _toggleSelectAll() {
    setState(() {
      if (isAllSelected) {
        // Clear selection
        selectedDays.clear();
        isAllSelected = false;
      } else {
        // Select all valid days (1 to 7)
        selectedDays = [0,1, 2, 3, 4, 5, 6, 7];
        isAllSelected = true;
      }
    });
  }

  void _toggleDay(int day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }

      // Update `isAllSelected` based on the current state of `selectedDays`
      isAllSelected = selectedDays.length == 7;
    });
  }


  //
  // void _initializeSelectedDays() {
  //   final now = DateTime.now();
  //   final localNow = now.toLocal();
  //   print('UTC Time: $now');
  //   print('Local Time: $localNow');
  //   print('Time Zone Offset: ${localNow.timeZoneOffset}');
  //
  //   final currentDay = localNow.weekday % 7;
  //   setState(() {
  //     selectedDays = [currentDay + 1];
  //   });
  // }
  //
  //
  // void _toggleSelectAll() {
  //   setState(() {
  //     if (isAllSelected) {
  //       selectedDays.clear();
  //       isAllSelected = false;
  //     } else {
  //       // Select all days
  //       selectedDays = [0, 1, 2, 3, 4, 5, 6,7];
  //       isAllSelected = true;
  //     }
  //   });
  // }
  // void _toggleDay(int day) {
  //   setState(() {
  //     if (selectedDays.contains(day)) {
  //       selectedDays.remove(day);
  //     } else {
  //       selectedDays.add(day);
  //     }
  //   });
  // }


  @override
  Widget build(BuildContext context) {
    final days = ["S", "M", "T", "W", "Th", "F", "St"];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      child: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: Form(
                key: widget.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/dialogImage.png',
                        height: 100, width: 100),
                    popupTitle(),
                    const SizedBox(height: 20),
                    textFormFields(),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _toggleSelectAll,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.select_all,
                              color: isAllSelected
                                  ? AppColors.primaryColor
                                  : Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            selectDays,
                            style: TextStyle(
                              color: isAllSelected
                                  ? AppColors.primaryColor
                                  : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(7, (index) {
                        final dayNum = index;
                        final isSelected = selectedDays.contains(dayNum);

                        return Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5),
                          child: GestureDetector(
                            onTap: () => _toggleDay(dayNum),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: isSelected
                                  ? AppColors.secondaryColor
                                  : Colors.grey[300],
                              child: Text(
                                days[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    // Column(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     // First row with 4 days
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: List.generate(4, (index) {
                    //         final dayNum = index + 1; // Day number from 1 to 4
                    //         final isSelected = selectedDays.contains(dayNum);
                    //
                    //         return Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 10),
                    //           child: GestureDetector(
                    //             onTap: () => _toggleDay(dayNum),
                    //             child: CircleAvatar(
                    //               radius: 25,
                    //               backgroundColor: isSelected
                    //                   ? AppColors.secondaryColor
                    //                   : Colors.grey[300],
                    //               child: Text(
                    //                 days[dayNum - 1], // Match `days` index
                    //                 style: TextStyle(
                    //                   color: isSelected ? Colors.white : Colors.black,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         );
                    //       }),
                    //     ),
                    //     const SizedBox(height: 20),
                    //
                    //     // Second row with 3 days
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: List.generate(3, (index) {
                    //         final dayNum = index + 5; // Day number from 5 to 7
                    //         final isSelected = selectedDays.contains(dayNum);
                    //
                    //         return Padding(
                    //           padding: const EdgeInsets.symmetric(horizontal: 10),
                    //           child: GestureDetector(
                    //             onTap: () => _toggleDay(dayNum),
                    //             child: CircleAvatar(
                    //               radius: 25,
                    //               backgroundColor: isSelected
                    //                   ? AppColors.secondaryColor
                    //                   : Colors.grey[300],
                    //               child: Text(
                    //                 days[dayNum - 1], // Match `days` index
                    //                 style: TextStyle(
                    //                   color: isSelected ? Colors.white : Colors.black,
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         );
                    //       }),
                    //     ),
                    //   ],
                    // ),sdf65

                    const SizedBox(height: 20),
                    actionButtons(context)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget actionButtons(BuildContext context) {


    final applianceProvider = Provider.of<ApplianceProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            if (widget.formKey.currentState!.validate()) {
              widget.addAppliance(selectedDays);
              Navigator.of(context).pop();

            }
            Future.delayed(const Duration(seconds: 2), () {
              applianceProvider.loadAppliances();
            });


          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget popupTitle() {
    return const Text('Add Appliance To Track',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ));
  }

  Widget textFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          TextFormField(
            controller: widget.addApplianceNameController,
            decoration: InputDecoration(
              labelText: 'Appliance Name',
              hintText: 'E.g. Rice Cooker',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onChanged: (value) {
              if (value.length > 16) {
                widget.addApplianceNameController.text = value.substring(0, 16);
                widget.addApplianceNameController.selection =
                    TextSelection.fromPosition(TextPosition(
                        offset: widget.addApplianceNameController.text.length));
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an appliance name';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: widget.addWattageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Wattage',
              hintText: 'E.g. 1000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onChanged: (value) {
              if (value.length > 4) {
                widget.addWattageController.text = value.substring(0, 4);
                widget.addWattageController.selection =
                    TextSelection.fromPosition(TextPosition(
                        offset: widget.addWattageController.text.length));
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the wattage';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),


          const SizedBox(height: 10),
          TextFormField(
            controller: widget.addUsagePatternController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Usage Pattern (hours per day)',
              hintText: 'E.g. 1',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onChanged: (value) {
              final doubleValue = double.tryParse(value);
              if (doubleValue != null && doubleValue > 24) {
                widget.addUsagePatternController.text = '24';
                widget.addUsagePatternController.selection = TextSelection.fromPosition(
                  const TextPosition(offset: '24'.length),
                );
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the usage pattern';
              }
              return null;
            },
          ),
          Row(
            children: [
              const Text('Minutes:'),
              const SizedBox(width: 10),
              DropdownButton<int>(
                value: selectedMinutes,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedMinutes = newValue ?? 0;
                  });
                  updateUsagePattern(); // Update hours with new minutes value
                },
                items: List.generate(60, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(index.toString()),
                  );
                }),
              ),
            ],
          ),

          // Dropdown for minutes selection
        ],
      ),
    );
  }

  int selectedMinutes = 30;

  // Method to update the TextController value with hours and minutes
  void updateUsagePattern() {
    double totalHours = selectedMinutes / 60.0; // Convert minutes to hours
    double currentHours = double.tryParse(widget.addUsagePatternController.text) ?? 0.0;
    double newHours = currentHours + totalHours;

    // Ensure the value doesn't exceed 24 hours
    if (newHours > 24) {
      newHours = 24;
    }

    // Update the controller's text with the new value (rounded to 2 decimal places)
    widget.addUsagePatternController.text = newHours.toStringAsFixed(2);
    widget.addUsagePatternController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.addUsagePatternController.text.length),
    );
  }
}
// TextFormField(
//   controller: widget.addUsagePatternController,
//   keyboardType: TextInputType.number,
//   decoration: InputDecoration(
//     labelText: 'Usage Pattern (hours per day)',
//     hintText: 'E.g. 1000',
//
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(20),
//     ),
//   ),
//   onChanged: (value) {
//     final doubleValue = double.tryParse(value);
//     if (doubleValue != null && doubleValue > 24) {
//       widget.addUsagePatternController.text = '24';
//       widget.addUsagePatternController.selection =
//           TextSelection.fromPosition(
//         const TextPosition(offset: '24'.length),
//       );
//     }
//   },
//   validator: (value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter the usage pattern';
//     }
//     return null;
//   },
// ),
// Row(
//   children: [
//     Column(
//       children: List.generate(3, (rowIndex) {
//         int startMinute = rowIndex * 10;
//         int endMinute = startMinute + 9;
//         return Row(
//           children: [
//             Text('$startMinute - $endMinute:'),
//             SizedBox(width: 10),
//             DropdownButton<int>(
//               value: selectedMinutes >= startMinute && selectedMinutes <= endMinute
//                   ? selectedMinutes
//                   : startMinute, // Set default to the start of the range
//               onChanged: (int? newValue) {
//                 setState(() {
//                   selectedMinutes = newValue ?? 0;
//                 });
//                 updateUsagePattern(); // Update hours with new minutes value
//               },
//               items: List.generate(10, (index) {
//                 int minute = startMinute + index;
//                 return DropdownMenuItem<int>(
//                   value: minute,
//                   child: Text(minute.toString()),
//                 );
//               }),
//             ),
//           ],
//         );
//       }),
//     ),
//
//     Column(
//       children: List.generate(3, (rowIndex) {
//         int startMinute = rowIndex * 10;
//         int endMinute = startMinute + 9;
//         return Row(
//           children: [
//             Text('$startMinute - $endMinute:'),
//             SizedBox(width: 10),
//             DropdownButton<int>(
//               value: selectedMinutes >= startMinute && selectedMinutes <= endMinute
//                   ? selectedMinutes
//                   : startMinute, // Set default to the start of the range
//               onChanged: (int? newValue) {
//                 setState(() {
//                   selectedMinutes = newValue ?? 0;
//                 });
//                 updateUsagePattern(); // Update hours with new minutes value
//               },
//               items: List.generate(10, (index) {
//                 int minute = startMinute + index;
//                 return DropdownMenuItem<int>(
//                   value: minute,
//                   child: Text(minute.toString()),
//                 );
//               }),
//             ),
//           ],
//         );
//       }),
//     ),
//   ],
// ),

class DropdownWithIcon extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final TextEditingController controller;
  final IconData icon;
  final FormFieldValidator<String>? validator;

  const DropdownWithIcon({
    super.key,
    required this.labelText,
    required this.items,
    required this.controller,
    required this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            value: controller.text.isNotEmpty ? controller.text : null,
            decoration: InputDecoration(
              labelText: labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              // suffixIcon: Icon(icon),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
            ),
            isExpanded: true,
            items: items.map<DropdownMenuItem<String>>((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.text = newValue;
              }
            },
            validator: validator,
          ),
        ),
      ],
    );
  }
}
