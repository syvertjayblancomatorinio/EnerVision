import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

class ApplianceInformationDialog extends StatefulWidget {
  final Map<String, dynamic> appliance;

  const ApplianceInformationDialog({
    Key? key,
    required this.appliance,
  }) : super(key: key);

  @override
  State<ApplianceInformationDialog> createState() =>
      _ApplianceInformationDialogState();
}

class _ApplianceInformationDialogState
    extends State<ApplianceInformationDialog> {
  final formatter = NumberFormat('#,##0.00', 'en_PHP');

  @override
  void initState() {
    super.initState();
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/appInfoImage.png',
                  fit: BoxFit.cover,
                  scale: 0.7,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${widget.appliance['applianceName']}',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                // style: Theme.of(context).textTheme.titleMedium,
              ),
              Column(
                children: [
                  KeyValueRow(
                    label: 'Wattage',
                    value: '${widget.appliance['wattage'] ?? 'N/A'} W',
                  ),
                  KeyValueRow(
                    label: 'Hours Used',
                    value:
                        '${widget.appliance['usagePatternPerDay'] ?? 'hours'} hours',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Text(
                          'Appliance Added on',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.appliance['createdAt'] != null
                              ? DateFormat('MM/dd/yyyy').format(
                                  DateTime.parse(widget.appliance['createdAt']))
                              : '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Text(
                          'Last Updated',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        // const Icon(Icons.calendar_month_outlined),
                        Text(
                          widget.appliance['updatedAt'] != null
                              ? DateFormat('MM/dd/yyyy').format(
                                  DateTime.parse(widget.appliance['createdAt']))
                              : '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  KeyValueRow(
                    label: 'Monthly Cost',
                    value:
                        'PHP ${formatter.format(widget.appliance['monthlyCost'] ?? 0)}',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;

  const KeyValueRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
