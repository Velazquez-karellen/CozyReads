import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/repositories/stats_repository.dart';
import 'models/reading_stats.dart';

final statsProvider = FutureProvider<ReadingStats>((ref) async {
  return StatsRepository().loadStats();
});
