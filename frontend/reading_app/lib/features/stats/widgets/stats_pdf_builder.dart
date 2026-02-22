import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../stats_models.dart';

class StatsPdfBuilder {
  // Cozy palette (soft, ghibli-ish)
  static final PdfColor _ink = PdfColor.fromInt(0xFF2B2B2B);
  static final PdfColor _muted = PdfColor.fromInt(0xFF6B6B6B);
  static final PdfColor _card = PdfColor.fromInt(0xFFF3EFE7);
  static final PdfColor _accent = PdfColor.fromInt(0xFF7AA6A1);

  static pw.Document build({
    required StatsOverview overview,
    required List<Map<String, dynamic>> runs,
    required bool exportOverview,
    required bool exportHistory,
    required bool exportRatings,
  }) {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (_) {
          final content = <pw.Widget>[];

          content.add(_header());
          content.add(pw.SizedBox(height: 18));

          if (exportOverview) {
            content.add(_sectionTitle('Overview'));
            content.add(pw.SizedBox(height: 10));
            content.add(_overviewCards(overview));
            content.add(pw.SizedBox(height: 16));

            content.add(_miniChart(
              title: 'Timeline (All)',
              data: overview.timelineAll,
              maxBars: 10,
            ));
            content.add(pw.SizedBox(height: 10));

            content.add(_miniChart(
              title: 'Re-reads breakdown',
              data: overview.rereadsBreakdown,
              maxBars: 10,
            ));

            content.add(pw.SizedBox(height: 18));
          }

          if (exportHistory) {
            content.add(_sectionTitle('Reading history'));
            content.add(pw.SizedBox(height: 10));

            // keep it tidy
            final history = runs.take(60).toList();
            for (final r in history) {
              final items = (r['items'] is Map) ? r['items'] as Map : null;
              final title = (items?['title'] as String?) ?? 'Unknown title';
              final type = (items?['type'] as String?) ?? 'unknown';
              final runNumber = r['run_number'] ?? 1;

              content.add(
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  decoration: pw.BoxDecoration(
                    color: _card,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              title,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _ink),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              '${type.toUpperCase()} • Run #$runNumber',
                              style: pw.TextStyle(color: _muted, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (runs.length > history.length) {
              content.add(
                pw.Text(
                  '...and ${runs.length - history.length} more',
                  style: pw.TextStyle(color: _muted, fontSize: 10),
                ),
              );
            }

            content.add(pw.SizedBox(height: 18));
          }

          if (exportRatings) {
            content.add(_sectionTitle('Ratings & reviews'));
            content.add(pw.SizedBox(height: 10));

            content.add(_miniChart(
              title: 'Ratings (Books)',
              data: overview.ratingsBooks,
              maxBars: 5,
            ));
            content.add(pw.SizedBox(height: 10));
            content.add(_miniChart(
              title: 'Ratings (Fanfics)',
              data: overview.ratingsFanfics,
              maxBars: 5,
            ));
            content.add(pw.SizedBox(height: 14));

            final rated = runs.where((r) => r['rating'] != null).take(40).toList();
            for (final r in rated) {
              final items = (r['items'] is Map) ? r['items'] as Map : null;
              final title = (items?['title'] as String?) ?? 'Unknown title';
              final rating = r['rating'];
              final review = (r['review'] as String?)?.trim();

              content.add(
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  margin: const pw.EdgeInsets.only(bottom: 8),
                  decoration: pw.BoxDecoration(
                    color: _card,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$title  ⭐ $rating',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _ink),
                      ),
                      if (review != null && review.isNotEmpty) ...[
                        pw.SizedBox(height: 6),
                        pw.Text(
                          '“$review”',
                          style: pw.TextStyle(color: _muted, fontStyle: pw.FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
          }

          return content;
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _header() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _card,
        borderRadius: pw.BorderRadius.circular(14),
        border: pw.Border.all(color: _accent, width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 12,
            height: 12,
            decoration: pw.BoxDecoration(
              color: _accent,
              borderRadius: pw.BorderRadius.circular(3),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'CozyReads',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Your Reading Stats (PDF export)',
                style: pw.TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        color: _ink,
      ),
    );
  }

  static pw.Widget _overviewCards(StatsOverview s) {
    pw.Widget card(String title, String value) {
      return pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: _card,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(color: _muted, fontSize: 10)),
              pw.SizedBox(height: 6),
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return pw.Row(
      children: [
        card('Books', s.books.toString()),
        pw.SizedBox(width: 10),
        card('Fanfics', s.fanfics.toString()),
        pw.SizedBox(width: 10),
        card('Avg rating (Books)', s.avgRatingBooks.toStringAsFixed(1)),
      ],
    );
  }

  static pw.Widget _miniChart({
    required String title,
    required Map<String, int> data,
    required int maxBars,
  }) {
    if (data.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _card,
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Text('$title: No data', style: pw.TextStyle(color: _muted)),
      );
    }

    final entries = data.entries.toList();
    // If too many, take last N (timeline) or top N
    final trimmed = entries.length <= maxBars ? entries : entries.sublist(entries.length - maxBars);

    final maxValue = trimmed.map((e) => e.value).fold<int>(0, (p, c) => c > p ? c : p);
    if (maxValue == 0) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _card,
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Text('$title: No data', style: pw.TextStyle(color: _muted)),
      );
    }

    pw.Widget barRow(String label, int value) {
      final pct = value / maxValue;
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 90,
              child: pw.Text(label, style: pw.TextStyle(fontSize: 9, color: _ink)),
            ),
            pw.Expanded(
              child: pw.Container(
                height: 8,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE8E2D8),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    width: 240 * pct,
                    decoration: pw.BoxDecoration(
                      color: _accent,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.SizedBox(
              width: 24,
              child: pw.Text(value.toString(), style: pw.TextStyle(fontSize: 9, color: _ink)),
            ),
          ],
        ),
      );
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _card,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _ink)),
          pw.SizedBox(height: 8),
          ...trimmed.map((e) => barRow(e.key, e.value)).toList(),
        ],
      ),
    );
  }
}
