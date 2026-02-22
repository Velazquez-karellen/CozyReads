import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/repositories/progress_repository.dart';
import '../../shared/repositories/item_repository.dart';

final progressRepositoryProvider =
Provider((_) => ProgressRepository());

final itemRepositoryProvider =
Provider((_) => ItemRepository());

final progressProvider =
StateNotifierProvider<ProgressNotifier, bool>(
      (ref) => ProgressNotifier(ref),
);

class ProgressNotifier extends StateNotifier<bool> {
  ProgressNotifier(this.ref) : super(false);
  final Ref ref;

  Future<void> saveProgress({
    required String itemId,
    required String runId,
    required int current,
    required int total,
    required bool isPages,
  }) async {
    state = true;

    final progressRepo = ref.read(progressRepositoryProvider);
    final itemRepo = ref.read(itemRepositoryProvider);

    await progressRepo.updateProgress(
      runId: runId,
      pages: isPages ? current : null,
      chapters: isPages ? null : current,
    );

    if (current >= total) {
      await progressRepo.finishRun(itemId);
      await itemRepo.updateStatus(
        itemId: itemId,
        status: 'finished',
      );
    } else {
      await itemRepo.updateStatus(
        itemId: itemId,
        status: 'reading',
      );
    }

    state = false;
  }
}
