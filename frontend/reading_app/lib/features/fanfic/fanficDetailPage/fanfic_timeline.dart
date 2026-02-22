import 'package:flutter/material.dart';
import '../../../shared/models/reading_run.dart';
import 'fanfic_reading_detail_page.dart';

class FanficTimeline extends StatelessWidget {
  final List<ReadingRun> runs;

  const FanficTimeline({super.key, required this.runs});

  @override
  Widget build(BuildContext context) {
    if (runs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reading history',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        ...runs.map((run) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FanficReadingDetailPage(run: run),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📖 Reading #${run.runNumber}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text('${run.progressChapters} chapters'),

                          if (run.rating != null) ...[
                            const SizedBox(height: 6),
                            Text('⭐ ${run.rating}'),
                          ],
                        ],
                      ),
                    ),

                    // QUOTES BUTTON
                    IconButton(
                      icon: const Icon(Icons.format_quote),
                      tooltip: 'Quotes',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FanficReadingDetailPage(run: run),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
