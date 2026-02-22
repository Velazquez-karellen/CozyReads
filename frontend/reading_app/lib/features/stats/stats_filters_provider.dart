import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StatsRange { all, year, month }

class StatsFilters {
  final StatsRange range;

  const StatsFilters({this.range = StatsRange.all});
}

class StatsFiltersNotifier extends StateNotifier<StatsFilters> {
  StatsFiltersNotifier() : super(const StatsFilters());

  void setRange(StatsRange range) {
    state = StatsFilters(range: range);
  }
}

final statsFiltersProvider =
StateNotifierProvider<StatsFiltersNotifier, StatsFilters>(
      (ref) => StatsFiltersNotifier(),
);
