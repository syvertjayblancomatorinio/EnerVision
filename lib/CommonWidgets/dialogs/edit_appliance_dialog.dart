import 'package:flutter/material.dart';

class EditApplianceDialog extends StatelessWidget {
  final TextEditingController editApplianceNameController;
  final TextEditingController editWattageController;
  final TextEditingController editUsagePatternController;
  final TextEditingController editWeeklyPatternController;
  final GlobalKey<FormState> formKey;
  final VoidCallback editAppliance;
  final Map<String, dynamic> appliance;
  final Future<void> Function(String, Map<String, dynamic>) updateAppliance;
  final VoidCallback fetchAppliances;
  final VoidCallback fetchDailyCosts;

  const EditApplianceDialog({
    Key? key,
    required this.editApplianceNameController,
    required this.editWattageController,
    required this.editUsagePatternController,
    required this.formKey,
    required this.editAppliance,
    required this.appliance,
    required this.updateAppliance,
    required this.fetchAppliances,
    required this.fetchDailyCosts,
    required this.editWeeklyPatternController,
  }) : super(key: key);

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/dialogImage.png', height: 100, width: 100),
                const SizedBox(height: 20),
                Text(
                  'Current Appliance: ${appliance['applianceName']}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: editApplianceNameController,
                  decoration: InputDecoration(
                    labelText: 'Enter New Appliance Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an appliance name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: editWattageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Wattage',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length > 6) {
                      editWattageController.text = value.substring(0, 6);
                      editWattageController.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: editWattageController.text.length));
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
                  controller: editUsagePatternController,
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
                      editUsagePatternController.text = '24';
                      editUsagePatternController.selection =
                          TextSelection.fromPosition(
                        const TextPosition(offset: '24'.length),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the usage pattern';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: editWeeklyPatternController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Usage Pattern (Days used per week)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onChanged: (value) {
                    final doubleValue = double.tryParse(value);
                    if (doubleValue != null && doubleValue > 7) {
                      editWeeklyPatternController.text = '7';
                      editWeeklyPatternController.selection =
                          TextSelection.fromPosition(
                        const TextPosition(offset: '7'.length),
                      );
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the usage pattern';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
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
                        _showSnackBar(context, 'Appliance was not updated');
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final updatedAppliance = {
                            'applianceName': editApplianceNameController.text,
                            'wattage': double.parse(editWattageController.text),
                            'usagePatternPerDay':
                                double.parse(editUsagePatternController.text),
                            'usagePatternPerWeek':
                                double.parse(editWeeklyPatternController.text),
                          };

                          updateAppliance(appliance['_id'], updatedAppliance)
                              .then((_) {
                            fetchAppliances();
                            fetchDailyCosts();

                            Navigator.of(context).pop();
                            _showSnackBar(
                                context, 'Appliance updated successfully!');
                          }).catchError((error) {
                            _showSnackBar(
                                context, 'Failed to update appliance');
                          });
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
