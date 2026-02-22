import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'recommendation_provider.dart';
import '../library/book_detail_page.dart';

class RecommendationResultPage extends ConsumerWidget {
  const RecommendationResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recommendationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your recommendations')),
      body: state.results.isEmpty
          ? const Center(
        child: Text(
          'No recommendations found 🌿\nTry a different mood.',
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.results.length,
        itemBuilder: (_, i) {
          final book = state.results[i];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BookDetailPage(book: book),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📘 Cover
                    Container(
                      width: 60,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(8),
                        color: Colors.grey.shade300,
                        image: book.coverUrl != null
                            ? DecorationImage(
                          image: NetworkImage(
                              book.coverUrl!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: book.coverUrl == null
                          ? const Icon(Icons.menu_book)
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // 📖 Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
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
                              Colors.grey.shade700,
                            ),
                          ),
                          if (book.genre != null)
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                  top: 6),
                              child: Text(
                                book.genre!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle:
                                  FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
