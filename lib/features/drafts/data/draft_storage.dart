import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/record_draft.dart';

class DraftStorage {
  static const boxName = 'record_drafts';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Box get box => Hive.box(boxName);

  static List<RecordDraft> list() {
    if (!Hive.isBoxOpen(boxName)) return [];
    return box.values
        .map((v) => RecordDraft.fromJson(Map<dynamic, dynamic>.from(v as Map)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  static Future<void> save(RecordDraft draft) async {
    await box.put(draft.id, draft.toJson());
  }

  static Future<void> delete(String id) async {
    await box.delete(id);
  }

  static RecordDraft? get(String id) {
    if (!Hive.isBoxOpen(boxName)) return null;
    final raw = box.get(id);
    if (raw == null) return null;
    return RecordDraft.fromJson(Map<dynamic, dynamic>.from(raw as Map));
  }

  static Future<String?> persistMediaFile(String? path, String prefix) async {
    if (path == null || path.isEmpty) return null;
    final source = File(path);
    if (!await source.exists()) return null;

    final dir = await getApplicationDocumentsDirectory();
    final draftsDir = Directory('${dir.path}/drafts');
    if (!await draftsDir.exists()) {
      await draftsDir.create(recursive: true);
    }

    final ext = source.path.contains('.')
        ? '.${source.path.split('.').last}'
        : '';
    final dest =
        '${draftsDir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}$ext';
    await source.copy(dest);
    return dest;
  }
}
