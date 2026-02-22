String _norm(String s) => s.trim().toLowerCase();

bool _containsAllTokens(String haystack, List<String> tokens) {
  for (final t in tokens) {
    if (!haystack.contains(t)) return false;
  }
  return true;
}

/// Generic filter:
/// - query: split into tokens, all tokens must match somewhere in the searchableText
/// - selectedTags: ALL selected tags must exist in itemTags (AND filter)
List<T> filterItems<T>({
  required List<T> items,
  required String query,
  required Set<String> selectedTags,
  required String Function(T item) searchableText,
  required Iterable<String> Function(T item) itemTags,
}) {
  final q = _norm(query);
  final tokens = q.isEmpty
      ? const <String>[]
      : q.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();

  return items.where((item) {
    final text = _norm(searchableText(item));

    // text query
    final queryOk = tokens.isEmpty ? true : _containsAllTokens(text, tokens);

    // tags AND filter
    final tags = itemTags(item).map((t) => _norm(t)).toSet();
    final tagsOk = selectedTags.isEmpty
        ? true
        : selectedTags.every((t) => tags.contains(_norm(t)));

    return queryOk && tagsOk;
  }).toList();
}
