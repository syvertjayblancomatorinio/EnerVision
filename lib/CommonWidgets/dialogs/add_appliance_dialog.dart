import 'package:flutter/material.dart';

class AddApplianceDialog extends StatelessWidget {
  final TextEditingController addApplianceNameController;
  final TextEditingController addWattageController;
  final TextEditingController addUsagePatternController;
  final TextEditingController addmonthlyPatternController;
  final GlobalKey<FormState> formKey;
  final VoidCallback addAppliance;

  const AddApplianceDialog({
    Key? key,
    required this.addApplianceNameController,
    required this.addWattageController,
    required this.addUsagePatternController,
    required this.formKey,
    required this.addAppliance,
    required this.addmonthlyPatternController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      const Text('Add Appliance To Track',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: addApplianceNameController,
                        decoration: InputDecoration(
                          labelText: 'Appliance Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length > 16) {
                            addApplianceNameController.text =
                                value.substring(0, 16);
                            addApplianceNameController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: addApplianceNameController
                                        .text.length));
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
                        controller: addWattageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Wattage',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length > 6) {
                            addWattageController.text = value.substring(0, 6);
                            addWattageController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: addWattageController.text.length));
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
                      TextFormField(
                        controller: addUsagePatternController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Usage Pattern (hours per day)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onChanged: (value) {
                          final doubleValue = double.tryParse(value);
                          if (doubleValue != null && doubleValue > 24) {
                            addUsagePatternController.text = '24';
                            addUsagePatternController.selection =
                                TextSelection.fromPosition(
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
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addmonthlyPatternController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Days used per Week',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onChanged: (value) {
                          final doubleValue = double.tryParse(value);
                          if (doubleValue != null && doubleValue > 7) {
                            addmonthlyPatternController.text = '7';
                            addmonthlyPatternController.selection =
                                TextSelection.fromPosition(
                              const TextPosition(offset: '7'.length),
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
                      const SizedBox(height: 20),
                      Row(
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
                              if (formKey.currentState!.validate()) {
                                addAppliance();
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -70.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white,
                ),
                width: 140,
                height: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child:
                      Image.asset('assets/dialogImage.png', fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
