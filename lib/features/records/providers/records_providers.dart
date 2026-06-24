import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/record.dart';
import '../data/record_repository.dart';

final recordsListProvider =
    AsyncNotifierProvider<RecordsListNotifier, RecordListResponse>(
  RecordsListNotifier.new,
);

class RecordsListNotifier extends AsyncNotifier<RecordListResponse> {
  @override
  Future<RecordListResponse> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<RecordListResponse> _load() {
    return ref.read(recordRepositoryProvider).fetchRecords();
  }
}

final recordDetailProvider =
    FutureProvider.family<Record, int>((ref, id) async {
  return ref.read(recordRepositoryProvider).fetchRecord(id);
});
