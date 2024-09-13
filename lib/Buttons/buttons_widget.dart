import 'package:flutter/material.dart';

Widget textButton(String text, VoidCallback onPressed) {
  return TextButton(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side:
            const BorderSide(color: Colors.grey), // Border color for the button
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: 24.0, vertical: 12.0), // Adjust padding as needed
    ),
    onPressed: onPressed,
    child: Text(
      text,
      style: const TextStyle(color: Colors.black), // Text color for the button
    ),
  );
}

Widget addButton(String text, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0) // Rounded corners
          ),
      backgroundColor: const Color(0xFF02A676),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    ),
    onPressed: onPressed,
    child: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
  );
}

Widget addAppliance(String text, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF02A676), // Background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    ),
    onPressed: onPressed,
    child: Text(text,
        style: TextStyle(color: Colors.white)), // Ensuring text color is white
  );
}

class AddApplianceButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  AddApplianceButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF02A676), // Background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
