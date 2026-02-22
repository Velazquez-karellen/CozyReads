import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/reading_item.dart';
import '../library/library_provider.dart';
import 'recommendation_models.dart';
import 'recommendation_provider.dart';
import 'recommendation_result_page.dart';

class RecommendationQuestionsPage extends ConsumerWidget {
  const RecommendationQuestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(recommendationProvider.notifier);
    final state = ref.watch(recommendationProvider);

    final books = ref.watch(toReadBooksProvider).maybeWhen(
      data: (l) => l,
      orElse: () => <ReadingItem>[],
    );

    final genres = books
        .map((b) => b.genre)
        .whereType<String>()
        .toSet()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your mood today')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'How are you feeling today?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReadingMood.values.map((m) {
                  return ChoiceChip(
                    label: Text(m.name),
                    selected: state.mood == m,
                    onSelected: (_) => notifier.setMood(m),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              const Text(
                'What kind of read do you want?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReadingLength.values.map((l) {
                  return ChoiceChip(
                    label: Text(l.name),
                    selected: state.length == l,
                    onSelected: (_) => notifier.setLength(l),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),
              const Text(
                'What genre are you in the mood for?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres.map((g) {
                  return ChoiceChip(
                    label: Text(g),
                    selected: state.genre == g,
                    onSelected: (_) => notifier.setGenre(g),
                  );
                }).toList(),
              ),

              const SizedBox(height: 48),
              Center(
                child: SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: state.mood != null &&
                        state.length != null &&
                        state.genre != null
                        ? () {
                      notifier.generate();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const RecommendationResultPage(),
                        ),
                      );
                    }
                        : null,
                    child: const Text('Recommend me'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
