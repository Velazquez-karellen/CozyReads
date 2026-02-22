import 'package:flutter/material.dart';
import '../../../shared/models/reading_run.dart';
import '../../../shared/models/quote.dart';
import '../../../shared/repositories/reading_repository.dart';

class FanficReadingDetailPage extends StatefulWidget {
  final ReadingRun run;

  const FanficReadingDetailPage({super.key, required this.run});

  @override
  State<FanficReadingDetailPage> createState() =>
      _FanficReadingDetailPageState();
}

class _FanficReadingDetailPageState
    extends State<FanficReadingDetailPage> {
  final ReadingRepository _repo = ReadingRepository();

  final TextEditingController _quoteCtrl = TextEditingController();
  final TextEditingController _chapterCtrl = TextEditingController();

  List<Quote> quotes = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  @override
  void dispose() {
    _quoteCtrl.dispose();
    _chapterCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    quotes = await _repo.getQuotesForRun(widget.run.id);
    setState(() => loading = false);
  }

  Future<void> _addQuote() async {
    final text = _quoteCtrl.text.trim();
    final chapter = int.tryParse(_chapterCtrl.text.trim());

    if (text.isEmpty || chapter == null) return;

    await _repo.addQuote(
      itemId: widget.run.itemId,
      runId: widget.run.id,
      pageOrChapter: chapter,
      text: text,
    );

    _quoteCtrl.clear();
    _chapterCtrl.clear();
    await _loadQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading #${widget.run.runNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================
            // PROGRESS / META
            // ======================
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('${widget.run.progressChapters} chapters'),

                  if (widget.run.rating != null) ...[
                    const SizedBox(height: 8),
                    Text('⭐ ${widget.run.rating}'),
                  ],

                  if (widget.run.review != null &&
                      widget.run.review!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      '“${widget.run.review!.trim()}”',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ======================
            // QUOTES
            // ======================
            Text(
              'Quotes',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

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
              child: Column(
                children: [
                  TextField(
                    controller: _quoteCtrl,
                    maxLines: 2,
                    decoration:
                    const InputDecoration(labelText: 'Quote'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _chapterCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                    const InputDecoration(labelText: 'Chapter'),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _addQuote,
                      child: const Text('Add quote'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (loading)
              const CircularProgressIndicator()
            else if (quotes.isEmpty)
              const Text(
                'No quotes saved for this reading.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...quotes.map(
                    (q) => Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    '“${q.text}” — ch. ${q.pageOrChapter}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
