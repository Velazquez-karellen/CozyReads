import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchState {
  final String query;
  final Set<String> selectedTags;

  const SearchState({
    this.query = '',
    this.selectedTags = const {},
  });

  SearchState copyWith({
    String? query,
    Set<String>? selectedTags,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());

  void setQuery(String v) {
    state = state.copyWith(query: v);
  }

  void toggleTag(String tag) {
    final next = {...state.selectedTags};

    if (next.contains(tag)) {
      next.remove(tag);
    } else {
      next.add(tag);
    }

    state = state.copyWith(selectedTags: next);
  }

  void clearTags() {
    state = state.copyWith(selectedTags: {});
  }

  void clearAll() {
    state = const SearchState();
  }
}

final searchProvider =
StateNotifierProvider<SearchNotifier, SearchState>(
      (ref) => SearchNotifier(),
);
