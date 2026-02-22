import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:reading_app/features/stats/widgets/stats_pdf_builder.dart';

import '../../../shared/services/supabase_service.dart';
import '../stats_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsExportButton extends ConsumerWidget {
  const StatsExportButton({super.key});

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    bool exportOverview = true;
    bool exportHistory = true;
    bool exportRatings = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Export your data'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Overview'),
                    value: exportOverview,
                    onChanged: (v) => setState(() => exportOverview = v ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Reading history'),
                    value: exportHistory,
                    onChanged: (v) => setState(() => exportHistory = v ?? false),
                  ),
                  CheckboxListTile(
                    title: const Text('Ratings & reviews'),
                    value: exportRatings,
                    onChanged: (v) => setState(() => exportRatings = v ?? false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: (exportOverview || exportHistory || exportRatings)
                      ? () => Navigator.pop(context, true)
                      : null,
                  child: const Text('Export PDF'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    // Pull stats overview from provider (already computed)
    final stats = await ref.read(statsDataProvider.future);

    // Fetch runs for PDF (include items)
    final client = SupabaseService.client;
    final runs = await client
        .from('reading_runs')
        .select('run_number, rating, review, start_time, end_time, items(title, type)')
        .not('end_time', 'is', null)
        .order('end_time', ascending: false);

    final runsList = List<Map<String, dynamic>>.from(runs);

    final pdf = StatsPdfBuilder.build(
      overview: stats,
      runs: runsList,
      exportOverview: exportOverview,
      exportHistory: exportHistory,
      exportRatings: exportRatings,
    );

    await Printing.layoutPdf(
      format: PdfPageFormat.a4,
      onLayout: (format) async => pdf.save(),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF exported successfully 📄')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.download),
      label: const Text('Export my data'),
      onPressed: () => _export(context, ref),
    );
  }
}
