import 'package:flutter/cupertino.dart';

void _showActionSheet(BuildContext context) {
  showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
            title: const Text('Appliance Actions'),
            message: const Text('Message'),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Default Action'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Action'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ));
}
