import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/draft_storage.dart';
import '../models/record_draft.dart';

final draftListProvider = Provider<List<RecordDraft>>((ref) {
  ref.watch(draftRefreshProvider);
  return DraftStorage.list();
});

final draftRefreshProvider = StateProvider<int>((ref) => 0);

void refreshDrafts(WidgetRef ref) {
  ref.read(draftRefreshProvider.notifier).state++;
}

void refreshDraftsFromRef(Ref ref) {
  ref.read(draftRefreshProvider.notifier).state++;
}
