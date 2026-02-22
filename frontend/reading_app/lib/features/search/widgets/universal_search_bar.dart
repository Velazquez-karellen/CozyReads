import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../search_provider.dart';

class UniversalSearchBar extends ConsumerWidget {
  final List<String> availableTags;
  final String hintText;

  const UniversalSearchBar({
    super.key,
    required this.availableTags,
    this.hintText = 'Search by title, author, genre, fandom, tags…',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    Future<void> openTagsSheet() async {
      await showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return Consumer(
            builder: (context, ref, _) {
              final state = ref.watch(searchProvider);
              final notifier = ref.read(searchProvider.notifier);

              final tags = availableTags.toList()..sort();

              if (tags.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No tags available yet.'),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  const Text(
                    'Filter by tags',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...tags.map((tag) {
                    final selected = state.selectedTags.contains(tag);

                    return CheckboxListTile(
                      value: selected,
                      onChanged: (_) => notifier.toggleTag(tag),
                      title: Text(tag),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }),
                  const SizedBox(height: 8),
                  if (state.selectedTags.isNotEmpty)
                    TextButton(
                      onPressed: notifier.clearTags,
                      child: const Text('Clear tags'),
                    ),
                ],
              );
            },
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: notifier.setQuery,
          controller: TextEditingController(text: state.query)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: state.query.length),
            ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Tags',
                  icon: const Icon(Icons.local_offer_outlined),
                  onPressed: openTagsSheet,
                ),
                if (state.query.isNotEmpty || state.selectedTags.isNotEmpty)
                  IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close),
                    onPressed: notifier.clearAll,
                  ),
              ],
            ),
          ),
        ),
        if (state.selectedTags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.selectedTags.map((t) {
              return InputChip(
                label: Text(t),
                onDeleted: () => notifier.toggleTag(t),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
