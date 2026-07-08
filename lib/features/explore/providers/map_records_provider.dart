import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/record.dart';
import '../../records/data/record_repository.dart';

/// 地圖可視範圍 bbox：`min_lng,min_lat,max_lng,max_lat`
final mapRecordsProvider =
    FutureProvider.family<RecordListResponse, String?>((ref, bbox) async {
  final repo = ref.watch(recordRepositoryProvider);
  return repo.fetchMapRecords(bbox: bbox);
});

void invalidateMapRecords(Ref ref) {
  ref.invalidate(mapRecordsProvider);
}
