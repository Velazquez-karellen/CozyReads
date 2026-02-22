import 'package:flutter/material.dart';
import '../../../shared/models/reading_item.dart';

class BookCard extends StatelessWidget {
  final ReadingItem book;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.onLongPress,
  });

  bool get isSagaBook => book.relatedTo != null;
  bool get isReading => book.status == 'reading';
  bool get isRead => book.status == 'finished';

  bool get usePages => book.totalPages != null;
  int get total =>
      usePages ? (book.totalPages ?? 0) : (book.totalChapters ?? 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: isSagaBook
              ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: isSagaBook
              ? Border.all(
            color: theme.colorScheme.primary.withOpacity(0.25),
            width: 1.2,
          )
              : null,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📘 COVER
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: book.coverUrl != null
                      ? Image.network(
                    book.coverUrl!,
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 60,
                    height: 90,
                    color:
                    theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.book, size: 32),
                  ),
                ),

                const SizedBox(width: 12),

                // 📚 INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        book.author,
                        style: TextStyle(
                          color:
                          theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      // 🏷️ TAGS
                      if (book.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: -6,
                          children: book.tags.map((t) {
                            return Chip(
                              label: Text(
                                t,
                                style:
                                const TextStyle(fontSize: 11),
                              ),
                              visualDensity:
                              VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],

                      // 📖 PROGRESS (READING) → %
                      if (isReading && total > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Progress: ${(book.ratingCount > 0 ? 100 : 50)}%',
                          // ⬆️ placeholder visual correcto
                          // (el % real solo vive en BookDetail)
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],

                      // ⭐ RATING (READ)
                      if (isRead && book.ratingCount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                                  (i) => Icon(
                                i < book.ratingAvg.floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${book.ratingAvg.toStringAsFixed(1)} (${book.ratingCount})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],

                      // 📚 SAGA
                      if (isSagaBook) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.collections_bookmark_outlined,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Part of a series',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
