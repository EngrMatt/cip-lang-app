import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/record.dart';
import '../data/record_repository.dart';

final recordsListProvider =
    AsyncNotifierProvider<RecordsListNotifier, RecordListResponse>(
  RecordsListNotifier.new,
);

class RecordsListNotifier extends AsyncNotifier<RecordListResponse> {
  static const _pageSize = 20;

  @override
  Future<RecordListResponse> build() => _load(page: 1);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(page: 1));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.items.length >= current.total) return;

    final nextPage = current.page + 1;
    final next = await _load(page: nextPage);
    state = AsyncData(
      RecordListResponse(
        items: [...current.items, ...next.items],
        total: next.total,
        page: nextPage,
        pageSize: _pageSize,
      ),
    );
  }

  Future<RecordListResponse> _load({required int page}) {
    return ref.read(recordRepositoryProvider).fetchRecords(
          page: page,
          pageSize: _pageSize,
        );
  }
}

final recordDetailProvider =
    FutureProvider.family<Record, int>((ref, id) async {
  return ref.read(recordRepositoryProvider).fetchRecord(id);
});
