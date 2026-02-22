import 'package:flutter/material.dart';
import '../stats_models.dart';

class StatsCozyMessage extends StatelessWidget {
  final StatsOverview overview;

  const StatsCozyMessage({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    String message = 'Keep reading 🌱';

    if (overview.fanfics > overview.books) {
      message = 'Fanfic has been your comfort lately ✨';
    } else if (overview.avgRating >= 4.5) {
      message = 'You’ve been loving your reads ⭐';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
