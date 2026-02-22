import 'package:flutter/material.dart';

import '../../../shared/models/reading_item.dart';
import '../../../shared/models/reading_run.dart';
import '../../../shared/repositories/reading_repository.dart';

class ProgressCard extends StatefulWidget {
  final ReadingItem book;
  final ReadingRun activeRun;

  // ✅ NUEVO: para refrescar el BookDetailPage y mostrar el botón “Finish & rate”
  final Future<void> Function()? onSaved;

  const ProgressCard({
    super.key,
    required this.book,
    required this.activeRun,
    this.onSaved,
  });

  @override
  State<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<ProgressCard> {
  final readingRepo = ReadingRepository();

  late TextEditingController _currentCtrl;
  bool saving = false;

  bool get usePages => widget.book.totalPages != null;

  int get total {
    if (usePages) return widget.book.totalPages ?? 0;
    return widget.book.totalChapters ?? 0;
  }

  int get current {
    if (usePages) return widget.activeRun.progressPages;
    return widget.activeRun.progressChapters;
  }

  double get ratio {
    if (total <= 0) return 0;
    return (current / total).clamp(0, 1);
  }

  @override
  void initState() {
    super.initState();
    _currentCtrl = TextEditingController(text: current.toString());
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    super.dispose();
  }

  Future<void> saveProgress() async {
    final parsed = int.tryParse(_currentCtrl.text.trim());
    if (parsed == null) return;

    final safeValue = parsed.clamp(0, total);

    setState(() => saving = true);

    try {
      if (usePages) {
        await readingRepo.updateRunProgressPages(
          runId: widget.activeRun.id,
          pages: safeValue,
        );
      } else {
        await readingRepo.updateRunProgressChapters(
          runId: widget.activeRun.id,
          chapters: safeValue,
        );
      }

      if (!mounted) return;

      // ✅ NO CAMBIAR STATUS AQUÍ
      // ✅ SOLO DAR FEEDBACK
      if (total > 0 && safeValue >= total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress complete! Now you can “Finish & rate ⭐”.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress saved ✅')),
        );
      }

      // ✅ refresca la pantalla padre para recalcular runs + mostrar botón finish
      if (widget.onSaved != null) {
        await widget.onSaved!();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving progress: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (total <= 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reading progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            LinearProgressIndicator(value: ratio),

            const SizedBox(height: 10),

            Text('${(ratio * 100).toStringAsFixed(1)}%'),

            const SizedBox(height: 14),

            Text(usePages ? 'Pages read' : 'Chapters read'),
            const SizedBox(height: 6),

            TextField(
              controller: _currentCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                helperText: 'Current: $current • Total: $total',
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : saveProgress,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text('Save progress'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
