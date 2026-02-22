import 'package:flutter/material.dart';
import '../../../shared/models/reading_item.dart';

class FanficHeader extends StatelessWidget {
  final ReadingItem fanfic;

  const FanficHeader({super.key, required this.fanfic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            fanfic.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 6),

          // Author
          Text(
            'by ${fanfic.author}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          // Fandom
          if (fanfic.fandom != null && fanfic.fandom!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                fanfic.fandom!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),

          const SizedBox(height: 12),

          // Rating
          if (fanfic.ratingCount > 0)
            Text(
              '⭐ ${fanfic.ratingAvg.toStringAsFixed(1)} '
                  '(${fanfic.ratingCount} readings)',
              style: Theme.of(context).textTheme.bodySmall,
            ),

          const SizedBox(height: 12),

          // Tags + Hiatus
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (fanfic.isHiatus)
                const Chip(
                  label: Text('HIATUS'),
                  backgroundColor: Colors.redAccent,
                ),
              ...fanfic.tags.map(
                    (t) => Chip(
                  label: Text(t),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
