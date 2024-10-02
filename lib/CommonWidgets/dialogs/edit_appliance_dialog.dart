import 'package:flutter/material.dart';

class EditApplianceDialog extends StatelessWidget {
  final TextEditingController editApplianceNameController;
  final TextEditingController editWattageController;
  final TextEditingController editUsagePatternController;
  final GlobalKey<FormState> formKey;
  final VoidCallback editAppliance;
  final Map<String, dynamic> appliance;
  final Future<void> Function(String, Map<String, dynamic>) updateAppliance;
  final VoidCallback fetchAppliances;

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
                            'usagePattern':
                                double.parse(editUsagePatternController.text),
                          };

                          updateAppliance(appliance['_id'], updatedAppliance)
                              .then((_) {
                            fetchAppliances();
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
