// confirm_delete_dialog.dart

import 'package:flutter/material.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String description;
  final Future<void> Function() onDelete;
  final Future<void> Function() postDelete;

  const ConfirmDeleteDialog({
    Key? key,
    required this.title,
    required this.description,
    required this.onDelete,
    required this.postDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 16,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: AppColors.primaryColor,
              size: 50,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onDelete().then((_) {
                      Navigator.of(context).pop();
                      postDelete();
                    }).catchError((error) {
                      print('Deletion failed: $error');
                      Navigator.of(context).pop(); // Close dialog even on error
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
