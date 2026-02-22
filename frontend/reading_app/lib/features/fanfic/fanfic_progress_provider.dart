import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/reading_run.dart';
import '../../shared/repositories/reading_repository.dart';

final readingRepositoryProvider = Provider((ref) => ReadingRepository());

final activeRunProvider =
FutureProvider.family<ReadingRun?, String>((ref, itemId) {
  return ref.read(readingRepositoryProvider).getActiveRunForItem(itemId);
});
