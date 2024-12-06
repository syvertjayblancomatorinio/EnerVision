import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../AuthService/base_url.dart';

class KwhRateDialog extends StatefulWidget {
  final TextEditingController kwhRateController;
  final Function(String kwhRate) saveKwhRate;
  final Function() fetchAppliances;
  final Function() fetchDailyCost;

  const KwhRateDialog({
    Key? key,
    required this.kwhRateController,
    required this.saveKwhRate,
    required this.fetchAppliances,
    required this.fetchDailyCost,
  }) : super(key: key);

  @override
  State<KwhRateDialog> createState() => _KwhRateDialogState();
}

class _KwhRateDialogState extends State<KwhRateDialog> {
  String? selectedProvider;
  Map<String, String> providers = {};

  Future<void> fetchProviders() async {
    try {
      final response =
          await http.get(Uri.parse('${ApiConfig.baseUrl}/api/providers'));
      if (response.statusCode == 200) {
        final List<dynamic> providerList = json.decode(response.body);
        providers = {
          for (var provider in providerList)
            provider['providerName']: provider['ratePerKwh'].toString()
        };
      } else {
        throw Exception('Failed to load providers');
      }
    } catch (e) {
      print('Error fetching providers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.electrical_services,
            size: 50,
            color: Colors.black,
          ),
          const SizedBox(height: 10),
          const Text(
            'Kilowatt-Hour Rate',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          FutureBuilder<void>(
            future: fetchProviders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Text('Error loading providers');
              } else {
                return DropdownButtonFormField<String>(
                  value: selectedProvider,
                  isExpanded: true,
                  hint: const Text('Select your Electric Service Provider'),
                  items: providers.keys.map((String provider) {
                    return DropdownMenuItem<String>(
                      value: provider,
                      child: Text(
                        provider,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14.0),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedProvider = newValue;
                      widget.kwhRateController.text = providers[newValue!]!;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 15),
          TextField(
            controller: widget.kwhRateController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Kilowatt Hour Rate (kWh)',
              hintStyle: const TextStyle(color: Colors.black),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 25.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFB1B1B1), width: 1),
                  ),
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 14.0)),
              ),
              ElevatedButton(
                onPressed: () async {
                  String kwhRate = widget.kwhRateController.text;
                  try {
                    await widget.saveKwhRate(kwhRate);
                    Navigator.of(context).pop();
                    widget.fetchAppliances();
                    widget.fetchDailyCost();
                  } catch (e) {
                    print('Failed to save kWh rate: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFF1BBC9B),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 14.0, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
