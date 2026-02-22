import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/reading_item.dart';
import '../../shared/models/quote.dart';
import '../../shared/repositories/item_repository.dart';
import '../../shared/repositories/reading_repository.dart';

import 'fanfic_provider.dart';
import 'fanfic_progress_provider.dart';
import 'fanfic_runs_provider.dart';

import 'fanficDetailPage/fanfic_header.dart';
import 'fanficDetailPage/fanfic_stats_row.dart';
import 'fanficDetailPage/fanfic_timeline.dart';
import 'fanficDetailPage/finish_fanfic_dialog.dart';

class FanficDetailPage extends ConsumerStatefulWidget {
  final ReadingItem fanfic;

  const FanficDetailPage({
    super.key,
    required this.fanfic,
  });

  @override
  ConsumerState<FanficDetailPage> createState() =>
      _FanficDetailPageState();
}

class _FanficDetailPageState
    extends ConsumerState<FanficDetailPage> {
  final ReadingRepository _readingRepo = ReadingRepository();
  final ItemRepository _itemRepo = ItemRepository();

  late ReadingItem _fanfic;

  final TextEditingController _progressCtrl = TextEditingController();
  final TextEditingController _quoteCtrl = TextEditingController();
  final TextEditingController _quoteChapterCtrl =
  TextEditingController();

  List<Quote> _quotes = [];
  bool _loadingQuotes = false;

  @override
  void initState() {
    super.initState();
    _fanfic = widget.fanfic;
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _quoteCtrl.dispose();
    _quoteChapterCtrl.dispose();
    super.dispose();
  }

  Future<void> _reloadFanfic() async {
    final fresh = await _itemRepo.getItemById(_fanfic.id);
    if (!mounted) return;
    setState(() => _fanfic = fresh);
  }

  Future<void> _loadQuotes(String runId) async {
    setState(() => _loadingQuotes = true);
    _quotes = await _readingRepo.getQuotesForRun(runId);
    setState(() => _loadingQuotes = false);
  }

  Future<void> _addQuote({
    required String runId,
  }) async {
    final text = _quoteCtrl.text.trim();
    final chapter =
    int.tryParse(_quoteChapterCtrl.text.trim());

    if (text.isEmpty || chapter == null) return;

    await _readingRepo.addQuote(
      itemId: _fanfic.id,
      runId: runId,
      pageOrChapter: chapter,
      text: text,
    );

    _quoteCtrl.clear();
    _quoteChapterCtrl.clear();

    await _loadQuotes(runId);
  }

  // =========================
  // EDIT FANFIC (LIKE BOOKS)
  // =========================
  Future<void> _editFanfic() async {
    final fandomCtrl =
    TextEditingController(text: _fanfic.fandom ?? '');
    final chaptersCtrl = TextEditingController(
        text: _fanfic.totalChapters?.toString() ?? '');
    final tagsCtrl =
    TextEditingController(text: _fanfic.tags.join(', '));
    final relatedCtrl =
    TextEditingController(text: _fanfic.relatedTo ?? '');

    String part = _fanfic.part;
    bool hiatus = _fanfic.isHiatus;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit fanfic info'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: fandomCtrl,
                decoration:
                const InputDecoration(labelText: 'Fandom'),
              ),
              TextField(
                controller: chaptersCtrl,
                keyboardType: TextInputType.number,
                decoration:
                const InputDecoration(labelText: 'Total chapters'),
              ),
              DropdownButtonFormField<String>(
                value: part,
                items: const [
                  DropdownMenuItem(value: 'main', child: Text('Main')),
                  DropdownMenuItem(
                      value: 'prequel', child: Text('Prequel')),
                  DropdownMenuItem(
                      value: 'sequel', child: Text('Sequel')),
                  DropdownMenuItem(
                      value: 'spin_off', child: Text('Spin-off')),
                ],
                onChanged: (v) => part = v!,
                decoration:
                const InputDecoration(labelText: 'Part'),
              ),
              CheckboxListTile(
                value: hiatus,
                onChanged: (v) => hiatus = v ?? false,
                title: const Text('On hiatus'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              TextField(
                controller: relatedCtrl,
                decoration: const InputDecoration(
                  labelText: 'Related to (fanfic id)',
                ),
              ),
              TextField(
                controller: tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    final newChapters = chaptersCtrl.text.isEmpty
        ? null
        : int.tryParse(chaptersCtrl.text);

    final tags = tagsCtrl.text
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();

    await _itemRepo.updateFanficMetadata(
      itemId: _fanfic.id,
      fandom: fandomCtrl.text.isEmpty ? null : fandomCtrl.text,
      totalChapters: newChapters,
      isHiatus: hiatus,
      part: part,
      relatedTo:
      relatedCtrl.text.isEmpty ? null : relatedCtrl.text,
      tags: tags,
    );

    ref.invalidate(fanficProvider);
    await _reloadFanfic();
  }

  @override
  Widget build(BuildContext context) {
    final activeRunAsync =
    ref.watch(activeRunProvider(_fanfic.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(_fanfic.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editFanfic,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FanficHeader(fanfic: _fanfic),
            const SizedBox(height: 16),
            activeRunAsync.when(
              data: (run) => FanficStatsRow(
                fanfic: _fanfic,
                activeRun: run,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // =========================
            // READING SECTION
            // =========================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: activeRunAsync.when(
                data: (run) {
                  if (run == null) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _readingRepo.startRun(_fanfic.id);
                          ref.invalidate(
                              activeRunProvider(_fanfic.id));
                        },
                        child: const Text('Start reading 📖'),
                      ),
                    );
                  }

                  final total = _fanfic.totalChapters ?? 0;
                  final current = run.progressChapters;
                  final percent = total == 0
                      ? 0.0
                      : (current / total).clamp(0.0, 1.0);

                  if (_quotes.isEmpty && !_loadingQuotes) {
                    _loadQuotes(run.id);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Progress: $current / $total chapters'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: percent),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _progressCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Update progress',
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _readingRepo
                                .updateRunProgressChapters(
                              runId: run.id,
                              chapters: int.tryParse(
                                  _progressCtrl.text) ??
                                  current,
                            );
                            ref.invalidate(
                                activeRunProvider(_fanfic.id));
                          },
                          child: const Text('Save progress'),
                        ),
                      ),

                      // =========================
                      // QUOTES
                      // =========================
                      const SizedBox(height: 24),
                      Text('Quotes',
                          style:
                          Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _quoteCtrl,
                        maxLines: 2,
                        decoration:
                        const InputDecoration(labelText: 'Quote'),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: _quoteChapterCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                        const InputDecoration(labelText: 'Chapter'),
                      ),
                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              _addQuote(runId: run.id),
                          child: const Text('Add quote'),
                        ),
                      ),

                      ..._quotes.map(
                            (q) => Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '“${q.text}” — ch. ${q.pageOrChapter}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),

                      if (percent >= 1.0)
                        Padding(
                          padding:
                          const EdgeInsets.only(top: 24),
                          child: ElevatedButton(
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (_) =>
                                    FinishFanficDialog(
                                      onSubmit:
                                          (rating, review) async {
                                        await _readingRepo.finishRun(
                                          runId: run.id,
                                          rating: rating,
                                          review: review,
                                        );
                                        ref.invalidate(activeRunProvider(
                                            _fanfic.id));
                                        ref.invalidate(
                                            fanficRunsProvider(_fanfic.id));
                                        ref.invalidate(fanficProvider);
                                        await _reloadFanfic();
                                      },
                                    ),
                              );
                            },
                            child: const Text('Finish & rate ⭐'),
                          ),
                        ),
                    ],
                  );
                },
                loading: () =>
                const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString()),
              ),
            ),

            const SizedBox(height: 32),

            ref.watch(fanficRunsProvider(_fanfic.id)).when(
              data: (runs) => FanficTimeline(
                runs: runs.where((r) => !r.isActive).toList(),
              ),
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(e.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
