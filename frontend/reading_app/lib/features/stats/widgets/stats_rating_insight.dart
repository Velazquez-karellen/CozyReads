import 'package:flutter/material.dart';
import 'stats_bar_chart.dart';

class StatsRatingInsight extends StatelessWidget {
  final Map<String, int> ratings;

  const StatsRatingInsight({super.key, required this.ratings});

  @override
  Widget build(BuildContext context) {
    return StatsBarChart(data: ratings);
  }
}
