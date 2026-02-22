import '../services/supabase_service.dart';

class ProgressRepository {
  final _client = SupabaseService.client;

  Future<Map<String, dynamic>?> getActiveRun(String itemId) async {
    final response = await _client
        .from('reading_runs')
        .select()
        .eq('item_id', itemId)
        .eq('is_active', true)
        .maybeSingle();

    return response;
  }

  Future<void> updateProgress({
    required String runId,
    int? pages,
    int? chapters,
  }) async {
    await _client.from('reading_runs').update({
      if (pages != null) 'progress_pages': pages,
      if (chapters != null) 'progress_chapters': chapters,
    }).eq('id', runId);
  }

  Future<void> finishRun(String itemId) async {
    await _client
        .from('reading_runs')
        .update({
      'is_active': false,
      'end_time': DateTime.now().toIso8601String(),
    })
        .eq('item_id', itemId)
        .eq('is_active', true);
  }
}
