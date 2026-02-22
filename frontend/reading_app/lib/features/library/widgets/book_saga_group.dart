import 'package:flutter/material.dart';
import '../../../shared/models/reading_item.dart';
import 'book_card.dart';

class BookSagaGroup extends StatelessWidget {
  final ReadingItem root;
  final List<ReadingItem> books;
  final Function(ReadingItem) onTap;
  final Function(ReadingItem) onLongPress;

  const BookSagaGroup({
    super.key,
    required this.root,
    required this.books,
    required this.onTap,
    required this.onLongPress,
  });

  // =========================
  // Helpers
  // =========================
  String _seriesName() {
    for (final t in root.tags) {
      if (t.startsWith('series_name:')) {
        return t.replaceFirst('series_name:', '');
      }
    }
    return 'Series';
  }

  String _seriesType() {
    for (final t in root.tags) {
      if (t.startsWith('series_type:')) {
        return t.replaceFirst('series_type:', '');
      }
    }
    return 'series';
  }

  String _pretty(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final type = _pretty(_seriesType());
    final name = _pretty(_seriesName());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🟣 HEADER
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Row(
            children: [
              const Icon(Icons.collections_bookmark, size: 18),
              const SizedBox(width: 8),
              Text(
                '$type · $name',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '(${books.length} books)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        // 📚 BOOKS
        ...books.map(
              (b) => BookCard(
            book: b,
            onTap: () => onTap(b),
            onLongPress: () => onLongPress(b),
          ),
        ),
      ],
    );
  }
}
