import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/services/supabase_service.dart';
import 'stats_models.dart';

final statsDataProvider = FutureProvider<StatsOverview>((ref) async {
  final client = SupabaseService.client;

  // ✅ IMPORTANT:
  // - Use items(...) to fetch the related item.
  // - But items can still be null (deleted item / RLS / bad data), so code below is null-safe.
  final runs = await client
      .from('reading_runs')
      .select('rating, run_number, start_time, end_time, item_id, items(title, type)')
      .not('end_time', 'is', null);

  int books = 0;
  int fanfics = 0;

  int rereads = 0;
  int rereadsBooks = 0;
  int rereadsFanfics = 0;

  int ratingSumAll = 0;
  int ratingCountAll = 0;

  int ratingSumBooks = 0;
  int ratingCountBooks = 0;

  int ratingSumFanfics = 0;
  int ratingCountFanfics = 0;

  // Charts
  final Map<String, int> timelineAll = {};
  final Map<String, int> timelineBooks = {};
  final Map<String, int> timelineFanfics = {};

  final Map<String, int> ratingsAll = {
    '1': 0, '2': 0, '3': 0, '4': 0, '5': 0,
  };
  final Map<String, int> ratingsBooks = {
    '1': 0, '2': 0, '3': 0, '4': 0, '5': 0,
  };
  final Map<String, int> ratingsFanfics = {
    '1': 0, '2': 0, '3': 0, '4': 0, '5': 0,
  };

  int firstReadsBooks = 0;
  int firstReadsFanfics = 0;

  for (final r in runs) {
    final items = r['items']; // may be null
    final String? type = (items is Map) ? items['type'] as String? : null;

    final runNumber = (r['run_number'] ?? 1) as int;

    // --------
    // Count type (ignore unknown)
    // --------
    if (type == 'book') books++;
    if (type == 'fanfic') fanfics++;

    // --------
    // Timeline (use end_time month as "completed month")
    // --------
    final endTimeRaw = r['end_time'] as String?;
    if (endTimeRaw != null) {
      final end = DateTime.tryParse(endTimeRaw);
      if (end != null) {
        final key = '${end.year}-${end.month.toString().padLeft(2, '0')}';

        timelineAll[key] = (timelineAll[key] ?? 0) + 1;
        if (type == 'book') {
          timelineBooks[key] = (timelineBooks[key] ?? 0) + 1;
        } else if (type == 'fanfic') {
          timelineFanfics[key] = (timelineFanfics[key] ?? 0) + 1;
        }
      }
    }

    // --------
    // Re-reads
    // --------
    if (runNumber > 1) {
      rereads++;
      if (type == 'book') rereadsBooks++;
      if (type == 'fanfic') rereadsFanfics++;
    } else {
      if (type == 'book') firstReadsBooks++;
      if (type == 'fanfic') firstReadsFanfics++;
    }

    // --------
    // Ratings
    // --------
    final rating = r['rating'] as int?;
    if (rating != null) {
      ratingSumAll += rating;
      ratingCountAll++;
      if (rating >= 1 && rating <= 5) {
        ratingsAll['$rating'] = (ratingsAll['$rating'] ?? 0) + 1;
      }

      if (type == 'book') {
        ratingSumBooks += rating;
        ratingCountBooks++;
        if (rating >= 1 && rating <= 5) {
          ratingsBooks['$rating'] = (ratingsBooks['$rating'] ?? 0) + 1;
        }
      } else if (type == 'fanfic') {
        ratingSumFanfics += rating;
        ratingCountFanfics++;
        if (rating >= 1 && rating <= 5) {
          ratingsFanfics['$rating'] = (ratingsFanfics['$rating'] ?? 0) + 1;
        }
      }
    }
  }

  double avgAll = ratingCountAll == 0 ? 0 : ratingSumAll / ratingCountAll;
  double avgBooks = ratingCountBooks == 0 ? 0 : ratingSumBooks / ratingCountBooks;
  double avgFanfics = ratingCountFanfics == 0 ? 0 : ratingSumFanfics / ratingCountFanfics;

  final rereadsBreakdown = <String, int>{
    'Books (1st)': firstReadsBooks,
    'Books (re)': rereadsBooks,
    'Fanfics (1st)': firstReadsFanfics,
    'Fanfics (re)': rereadsFanfics,
  };

  // Ensure timeline keys are sorted (nice charts ordering)
  Map<String, int> _sortedMap(Map<String, int> m) {
    final keys = m.keys.toList()..sort();
    return {for (final k in keys) k: m[k] ?? 0};
  }

  return StatsOverview(
    books: books,
    fanfics: fanfics,
    rereads: rereads,
    rereadsBooks: rereadsBooks,
    rereadsFanfics: rereadsFanfics,
    avgRating: avgAll,
    avgRatingBooks: avgBooks,
    avgRatingFanfics: avgFanfics,
    timelineAll: _sortedMap(timelineAll),
    timelineBooks: _sortedMap(timelineBooks),
    timelineFanfics: _sortedMap(timelineFanfics),
    ratingsAll: ratingsAll,
    ratingsBooks: ratingsBooks,
    ratingsFanfics: ratingsFanfics,
    rereadsBreakdown: rereadsBreakdown,
  );
});
