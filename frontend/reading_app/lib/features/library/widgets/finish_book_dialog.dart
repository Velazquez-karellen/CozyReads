import 'package:flutter/material.dart';

class FinishBookDialog extends StatefulWidget {
  final bool askPhysical;

  const FinishBookDialog({super.key, required this.askPhysical});

  @override
  State<FinishBookDialog> createState() => _FinishBookDialogState();
}

class _FinishBookDialogState extends State<FinishBookDialog> {
  int rating = 0;
  final reviewCtrl = TextEditingController();
  bool? wouldBuyPhysical;

  bool get valid =>
      rating > 0 &&
          reviewCtrl.text.trim().isNotEmpty &&
          (!widget.askPhysical || wouldBuyPhysical != null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Finish book'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your rating'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final value = i + 1;
                return IconButton(
                  icon: Icon(
                    value <= rating ? Icons.star : Icons.star_border,
                  ),
                  onPressed: () => setState(() => rating = value),
                );
              }),
            ),

            const SizedBox(height: 16),
            const Text('Your review'),
            const SizedBox(height: 8),
            TextField(
              controller: reviewCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts about this book…',
                border: OutlineInputBorder(),
              ),
            ),

            if (widget.askPhysical) ...[
              const SizedBox(height: 16),
              const Text('Would you buy it in physical format?'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Yes'),
                      value: true,
                      groupValue: wouldBuyPhysical,
                      onChanged: (v) =>
                          setState(() => wouldBuyPhysical = v),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('No'),
                      value: false,
                      groupValue: wouldBuyPhysical,
                      onChanged: (v) =>
                          setState(() => wouldBuyPhysical = v),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: valid ? () {
            Navigator.pop(context, {
              'rating': rating,
              'review': reviewCtrl.text.trim(),
              'wouldBuyPhysical': wouldBuyPhysical,
            });
          } : null,
          child: const Text('Finish'),
        ),
      ],
    );
  }
}
