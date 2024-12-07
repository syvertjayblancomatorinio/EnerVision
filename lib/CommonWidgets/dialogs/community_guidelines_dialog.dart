import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/final_texts.dart'; // Assuming your descriptions are defined here
import 'package:supabase_project/ConstantTexts/colors.dart'; // Assuming you have a color scheme here


class CommunityGuidelinesDialog extends StatefulWidget {
  final Function onAccept;

  CommunityGuidelinesDialog({required this.onAccept});

  @override
  _CommunityGuidelinesDialogState createState() =>
      _CommunityGuidelinesDialogState();
}

class _CommunityGuidelinesDialogState extends State<CommunityGuidelinesDialog> {
  bool _hasAcknowledged = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: const Text(
        "Community Guidelines",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
      ),
      content: SizedBox(
        height:
        MediaQuery.of(context).size.height * 0.6, // 60% of screen height
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '''Welcome to our community! Here are some guidelines you should follow when posting and interacting with others:''',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16.0),
              _description(context, descriptions), // Show guidelines
              CheckboxListTile(
                title: const Text(
                  "I acknowledge and agree to follow the Community Guidelines",
                  style: TextStyle(fontFamily: 'Montserrat'),
                ),
                value: _hasAcknowledged,
                onChanged: (bool? value) {
                  setState(() {
                    _hasAcknowledged = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFF1BBC9B),
                checkColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(
            "Cancel",
            style: TextStyle(color: AppColors.secondaryColor),
          ),
        ),
        ElevatedButton(
          onPressed: _hasAcknowledged
              ? () {
            widget.onAccept();
            Navigator.of(context).pop();
          }
              : null, // Disabled when _hasAcknowledged is false
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasAcknowledged
                ? const Color(0xFF1BBC9B) // Green when acknowledged
                : Colors.grey, // Grey when disabled
          ),
          child: const Text("Accept"),
        ),
      ],
    );
  }

  Widget _description(BuildContext context, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 8.0), // spacing between sections
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title'] ?? '',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey[700]),
              ),
              const SizedBox(height: 4.0),
              ..._buildDescriptionList(item['description']
              as List<String>), // Handle multiple bullet points
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildDescriptionList(List<String> descriptions) {
    return descriptions.map((desc) {
      return Padding(
        padding: const EdgeInsets.only(
            left: 20.0, top: 4.0), // 20 px indentation for bullet points
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ",
                style: TextStyle(fontSize: 16)), // Bullet point symbol
            Expanded(
              child: Text(
                desc,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
