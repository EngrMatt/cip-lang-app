import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/record.dart';
import '../data/record_repository.dart';

enum MediaFilter { all, hasAudio, hasImage, basicOnly }

class RecordListFilter {
  const RecordListFilter({
    this.category,
    this.mediaFilter = MediaFilter.all,
  });

  final String? category;
  final MediaFilter mediaFilter;
}

final recordListFilterProvider =
    NotifierProvider<RecordListFilterNotifier, RecordListFilter>(
  RecordListFilterNotifier.new,
);

class RecordListFilterNotifier extends Notifier<RecordListFilter> {
  @override
  RecordListFilter build() => const RecordListFilter();

  void setCategory(String? category) {
    state = RecordListFilter(
      category: category,
      mediaFilter: state.mediaFilter,
    );
    ref.invalidate(recordsListProvider);
  }

  void setMediaFilter(MediaFilter mediaFilter) {
    state = RecordListFilter(
      category: state.category,
      mediaFilter: state.mediaFilter == mediaFilter
          ? MediaFilter.all
          : mediaFilter,
    );
  }
}

final recordsListProvider =
    AsyncNotifierProvider<RecordsListNotifier, RecordListResponse>(
  RecordsListNotifier.new,
);

class RecordsListNotifier extends AsyncNotifier<RecordListResponse> {
  static const _pageSize = 20;

  @override
  Future<RecordListResponse> build() async {
    ref.watch(recordListFilterProvider.select((f) => f.category));
    ref.watch(recordListFilterProvider.select((f) => f.mediaFilter));
    return _load(page: 1);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(page: 1));
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null) return;

    final filter = ref.read(recordListFilterProvider);
    final nextPage = (current.page ?? 1) + 1;
    final next = await _fetchPage(page: nextPage, category: filter.category);
    final merged = RecordListResponse(
      items: [...current.items, ...next.items],
      total: next.total,
      page: nextPage,
      pageSize: _pageSize,
    );
    state = AsyncData(_applyMediaFilter(merged, filter.mediaFilter));
  }

  Future<RecordListResponse> _load({required int page}) async {
    final filter = ref.read(recordListFilterProvider);
    final raw = await _fetchPage(page: page, category: filter.category);
    return _applyMediaFilter(raw, filter.mediaFilter);
  }

  Future<RecordListResponse> _fetchPage({
    required int page,
    String? category,
  }) {
    return ref.read(recordRepositoryProvider).fetchRecords(
          page: page,
          pageSize: _pageSize,
          category: category,
        );
  }

  RecordListResponse _applyMediaFilter(
    RecordListResponse raw,
    MediaFilter mediaFilter,
  ) {
    if (mediaFilter == MediaFilter.all) return raw;

    final filtered = raw.items.where((record) {
      return switch (mediaFilter) {
        MediaFilter.hasAudio => record.audioUrl != null,
        MediaFilter.hasImage => record.imageUrl != null,
        MediaFilter.basicOnly =>
          record.audioUrl == null && record.imageUrl == null,
        MediaFilter.all => true,
      };
    }).toList();

    return RecordListResponse(
      items: filtered,
      total: raw.total,
      page: raw.page,
      pageSize: raw.pageSize,
    );
  }
}

final recordDetailProvider =
    FutureProvider.family<Record, int>((ref, id) async {
  return ref.read(recordRepositoryProvider).fetchRecord(id);
});
