import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/services/supabase_service.dart';

class StatsDetailPage extends ConsumerWidget {
  final String type; // 'book' | 'fanfic'

  const StatsDetailPage({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = type == 'book' ? 'Books history' : 'Fanfics history';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchRuns(type),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final runs = snapshot.data ?? [];

          if (runs.isEmpty) {
            return const Center(
              child: Text('No reading history yet 🌱'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: runs.length,
            itemBuilder: (context, i) {
              final r = runs[i];

              final items = (r['items'] is Map) ? r['items'] as Map<String, dynamic> : null;
              final title = (items?['title'] as String?) ?? 'Unknown title';

              final startRaw = r['start_time'] as String?;
              final endRaw = r['end_time'] as String?;

              final start = startRaw != null ? DateTime.tryParse(startRaw) : null;
              final end = endRaw != null ? DateTime.tryParse(endRaw) : null;

              int? durationDays;
              if (start != null && end != null) {
                durationDays = end.difference(start).inDays;
                if (durationDays < 0) durationDays = 0; // safety if timezone weirdness
              }

              final runNumber = (r['run_number'] ?? 1) as int;

              final rating = r['rating'] as int?;
              final review = r['review'] as String?;

              final isReread = runNumber > 1;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Run #$runNumber${isReread ? ' • Re-read' : ''}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(Icons.play_arrow, size: 16),
                          const SizedBox(width: 6),
                          Text('Started: ${_fmt(start)}'),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.stop, size: 16),
                          const SizedBox(width: 6),
                          Text('Finished: ${_fmt(end)}'),
                        ],
                      ),

                      if (durationDays != null) ...[
                        const SizedBox(height: 8),
                        Text('⏱️ Duration: $durationDays days'),
                      ],

                      if (rating != null) ...[
                        const SizedBox(height: 10),
                        Text('⭐ Rating: $rating'),
                      ],

                      if (review != null && review.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '“${review.trim()}”',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRuns(String type) async {
    final client = SupabaseService.client;

    // ✅ Use inner join to ensure items exists when filtering by type.
    // If some runs point to deleted items, they won't appear (good for stability).
    final data = await client
        .from('reading_runs')
        .select('run_number, rating, review, start_time, end_time, items!inner(title, type)')
        .eq('items.type', type)
        .order('start_time', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
