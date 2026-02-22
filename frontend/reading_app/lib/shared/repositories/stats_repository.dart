import '../services/supabase_service.dart';
import '../../features/stats/models/reading_stats.dart';

class StatsRepository {
  final _client = SupabaseService.client;

  Future<ReadingStats> loadStats() async {
    final userId = _client.auth.currentUser!.id;

    final items = await _client
        .from('items')
        .select()
        .eq('user_id', userId);

    final runs = await _client
        .from('reading_runs')
        .select()
        .eq('user_id', userId);

    int count(String status) =>
        items.where((e) => e['status'] == status).length;

    final now = DateTime.now();
    final finishedThisMonth = items.where((e) {
      if (e['status'] != 'finished') return false;
      final updated = DateTime.parse(e['updated_at']);
      return updated.month == now.month && updated.year == now.year;
    }).length;

    final avgRating = items.isEmpty
        ? 0.0
        : items
        .map((e) => ((e['rating_avg'] ?? 0) as num).toDouble())
        .reduce((a, b) => a + b) /
        items.length;

    final totalProgress = runs.fold<int>(
      0,
          (sum, r) =>
      sum +
          ((r['progress_pages'] ?? 0) as int) +
          ((r['progress_chapters'] ?? 0) as int),
    );

    return ReadingStats(
      toRead: count('to_read'),
      reading: count('reading'),
      finished: count('finished'),
      finishedThisMonth: finishedThisMonth,
      avgRating: avgRating,
      totalProgress: totalProgress,
      totalRuns: runs.length,
      streak: 0, // preparado para expansión
    );
  }
}
