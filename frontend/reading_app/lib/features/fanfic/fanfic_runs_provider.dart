import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/reading_run.dart';
import '../../shared/repositories/reading_repository.dart';

final readingRepositoryProvider = Provider((ref) => ReadingRepository());

final fanficRunsProvider =
FutureProvider.family<List<ReadingRun>, String>((ref, itemId) async {
  final repo = ref.read(readingRepositoryProvider);
  return repo.getRunsForItem(itemId);
});
