import 'package:flutter/material.dart';

Future<int?> showEditQuantityDialog(
  BuildContext context, {
  required int current,
  int min = 1,
  int max = 99,
  String title = 'Edit quantity',
}) {
  final TextEditingController controller =
      TextEditingController(text: current.toString());
  String? errorText;

  return showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return StatefulBuilder(builder: (context, setState) {
        void validateAndSubmit() {
          final text = controller.text.trim();
          final parsed = int.tryParse(text);
          if (parsed == null) {
            setState(() => errorText = 'Please enter a valid integer');
            return;
          }
          if (parsed < min || parsed > max) {
            setState(() => errorText = 'Enter a value between $min and $max');
            return;
          }
          Navigator.of(context).pop(parsed);
        }

        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  errorText: errorText,
                ),
                onSubmitted: (_) => validateAndSubmit(),
              ),
              const SizedBox(height: 8),
              Text('Enter a whole number between $min and $max.',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: validateAndSubmit,
              child: const Text('Save'),
            ),
          ],
        );
      });
    },
  );
}
