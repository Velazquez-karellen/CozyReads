import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/repositories/item_repository.dart';
import 'fanfic_provider.dart';

class AddFanficPage extends ConsumerStatefulWidget {
  const AddFanficPage({super.key});

  @override
  ConsumerState<AddFanficPage> createState() => _AddFanficPageState();
}

class _AddFanficPageState extends ConsumerState<AddFanficPage> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _fandomCtrl = TextEditingController();
  final _chaptersCtrl = TextEditingController();
  final _customTagsCtrl = TextEditingController();

  String part = 'main';
  String? relatedFanficId;
  bool hiatus = false;

  /// language tag
  String language = 'english';

  final repo = ItemRepository();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _fandomCtrl.dispose();
    _chaptersCtrl.dispose();
    _customTagsCtrl.dispose();
    super.dispose();
  }

  Future<void> saveFanfic() async {
    final customTags = _customTagsCtrl.text
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();

    final finalTags = <String>{
      ...customTags,
      language,
      'part:$part',
      if (relatedFanficId != null) 'related:$relatedFanficId',
    }.toList();

    await repo.addFanfic(
      title: _titleCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      fandom: _fandomCtrl.text.trim(),
      totalChapters: int.tryParse(_chaptersCtrl.text),
      part: part,
      isHiatus: hiatus,
      tags: finalTags,

      // ✅ THE FIX:
      relatedTo: relatedFanficId,
    );

    ref.invalidate(fanficProvider);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final fanficsAsync = ref.watch(fanficProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Fanfic')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _authorCtrl,
              decoration: const InputDecoration(labelText: 'Author'),
            ),
            TextField(
              controller: _fandomCtrl,
              decoration: const InputDecoration(labelText: 'Fandom'),
            ),
            TextField(
              controller: _chaptersCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total chapters'),
            ),

            const SizedBox(height: 20),

            // =====================
            // LANGUAGE
            // =====================
            Text(
              'Language',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('English'),
                  selected: language == 'english',
                  onSelected: (_) => setState(() => language = 'english'),
                ),
                ChoiceChip(
                  label: const Text('Español'),
                  selected: language == 'spanish',
                  onSelected: (_) => setState(() => language = 'spanish'),
                ),
                ChoiceChip(
                  label: const Text('Other'),
                  selected: language == 'other-language',
                  onSelected: (_) => setState(() => language = 'other-language'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // =====================
            // PART
            // =====================
            DropdownButtonFormField<String>(
              initialValue: part,
              items: const [
                DropdownMenuItem(value: 'main', child: Text('Main')),
                DropdownMenuItem(value: 'prequel', child: Text('Prequel')),
                DropdownMenuItem(value: 'sequel', child: Text('Sequel')),
                DropdownMenuItem(value: 'spin_off', child: Text('Spin-off')),
              ],
              onChanged: (v) {
                setState(() {
                  part = v!;
                  if (part == 'main') relatedFanficId = null;
                });
              },
              decoration: const InputDecoration(labelText: 'Part'),
            ),

            if (part != 'main') ...[
              const SizedBox(height: 12),
              fanficsAsync.when(
                data: (list) => DropdownButtonFormField<String>(
                  initialValue: relatedFanficId,
                  items: list
                      .where((f) => f.part == 'main')
                      .map((f) => DropdownMenuItem(
                    value: f.id,
                    child: Text(f.title),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => relatedFanficId = v),
                  decoration: const InputDecoration(labelText: 'Related to'),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString()),
              ),
            ],

            const SizedBox(height: 16),

            CheckboxListTile(
              value: hiatus,
              onChanged: (v) => setState(() => hiatus = v ?? false),
              title: const Text('This fanfic is on hiatus'),
              controlAffinity: ListTileControlAffinity.leading,
            ),

            const SizedBox(height: 20),

            // =====================
            // TAGS
            // =====================
            TextField(
              controller: _customTagsCtrl,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'angst, slow burn, enemies to lovers',
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: part != 'main' && relatedFanficId == null ? null : saveFanfic,
                child: const Text('Save fanfic'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
