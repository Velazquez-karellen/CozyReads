import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/reading_item.dart';
import '../library/library_provider.dart';
import 'recommendation_models.dart';

class RecommendationState {
  final ReadingMood? mood;
  final ReadingLength? length;
  final String? genre;
  final List<ReadingItem> results;

  const RecommendationState({
    this.mood,
    this.length,
    this.genre,
    this.results = const [],
  });

  RecommendationState copyWith({
    ReadingMood? mood,
    ReadingLength? length,
    String? genre,
    List<ReadingItem>? results,
  }) {
    return RecommendationState(
      mood: mood ?? this.mood,
      length: length ?? this.length,
      genre: genre ?? this.genre,
      results: results ?? this.results,
    );
  }
}

class RecommendationNotifier extends StateNotifier<RecommendationState> {
  RecommendationNotifier(this._toReadBooks)
      : super(const RecommendationState());

  final List<ReadingItem> _toReadBooks;

  void setMood(ReadingMood v) {
    state = state.copyWith(mood: v);
  }

  void setLength(ReadingLength v) {
    state = state.copyWith(length: v);
  }

  void setGenre(String v) {
    state = state.copyWith(genre: v);
  }

  void generate() {
    final scored = <ReadingItem, int>{};

    for (final book in _toReadBooks) {
      int score = 0;

      // Genre match
      if (state.genre != null &&
          book.genre != null &&
          book.genre!.toLowerCase() ==
              state.genre!.toLowerCase()) {
        score += 2;
      }

      // Mood match (simple tag-based heuristics)
      final tags = (book.tags).map((e) => e.toLowerCase()).toList();

      switch (state.mood) {
        case ReadingMood.calm:
          if (tags.any((t) => ['slice of life', 'cozy', 'romance'].contains(t))) {
            score += 1;
          }
          break;
        case ReadingMood.energetic:
          if (tags.any((t) => ['fantasy', 'action', 'adventure'].contains(t))) {
            score += 1;
          }
          break;
        case ReadingMood.thoughtful:
          if (tags.any((t) => ['philosophy', 'mystery', 'psychological'].contains(t))) {
            score += 1;
          }
          break;
        case ReadingMood.emotional:
          if (tags.any((t) => ['drama', 'romance'].contains(t))) {
            score += 1;
          }
          break;
        default:
          break;
      }

      // Length match
      final pages = book.totalPages ?? 0;
      switch (state.length) {
        case ReadingLength.short:
          if (pages > 0 && pages < 250) score += 1;
          break;
        case ReadingLength.medium:
          if (pages >= 250 && pages <= 400) score += 1;
          break;
        case ReadingLength.long:
          if (pages > 400) score += 1;
          break;
        default:
          break;
      }

      scored[book] = score;
    }

    final sorted = scored.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    state = state.copyWith(
      results: sorted.take(3).map((e) => e.key).toList(),
    );
  }

  void reset() {
    state = const RecommendationState();
  }
}

final recommendationProvider =
StateNotifierProvider<RecommendationNotifier, RecommendationState>(
      (ref) {
    final toRead = ref.watch(toReadBooksProvider).maybeWhen(
      data: (list) => list,
      orElse: () => <ReadingItem>[],
    );
    return RecommendationNotifier(toRead);
  },
);
