import 'package:flutter/material.dart';

class FinishFanficDialog extends StatefulWidget {
  final void Function(int rating, String review) onSubmit;

  const FinishFanficDialog({super.key, required this.onSubmit});

  @override
  State<FinishFanficDialog> createState() => _FinishFanficDialogState();
}

class _FinishFanficDialogState extends State<FinishFanficDialog> {
  int rating = 0;
  final reviewCtrl = TextEditingController();

  @override
  void dispose() {
    reviewCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Finish fanfic'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final index = i + 1;
              return IconButton(
                icon: Icon(
                  index <= rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() => rating = index);
                },
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reviewCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Review',
              hintText: 'What did you think?',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: rating == 0
              ? null
              : () {
            widget.onSubmit(
              rating,
              reviewCtrl.text.trim(),
            );
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
