import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/reading_item.dart';
import '../../../shared/models/reading_run.dart';
import '../fanfic_runs_provider.dart';

class FanficStatsRow extends ConsumerWidget {
  final ReadingItem fanfic;
  final ReadingRun? activeRun;

  const FanficStatsRow({
    super.key,
    required this.fanfic,
    required this.activeRun,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = fanfic.totalChapters ?? 0;

    final runsAsync = ref.watch(fanficRunsProvider(fanfic.id));

    int current = 0;

    if (activeRun != null) {
      current = activeRun!.progressChapters;
    } else {
      runsAsync.whenData((runs) {
        if (runs.isEmpty) return;
      });

      final runs = runsAsync.asData?.value ?? const <ReadingRun>[];
      if (runs.isNotEmpty) {
        final maxProgress = runs
            .map((r) => r.progressChapters)
            .fold<int>(0, (a, b) => max(a, b));
        current = maxProgress;
      } else {
        current = 0;
      }
    }

    if (total > 0) {
      current = current.clamp(0, total);
    }

    final double percent = total == 0 ? 0.0 : (current / total).clamp(0.0, 1.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Chapters
        Text(
          total == 0 ? '— / — chapters' : '$current / $total chapters',
          style: Theme.of(context).textTheme.bodySmall,
        ),

        // Rating avg (global)
        if (fanfic.ratingCount > 0)
          Text(
            '⭐ ${fanfic.ratingAvg.toStringAsFixed(1)} (${fanfic.ratingCount})',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w500),
          )
        else
          Text(
            '${(percent * 100).round()}%',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w500),
          ),

        // Part
        if (fanfic.part != 'main')
          Text(
            fanfic.part,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
      ],
    );
  }
}
