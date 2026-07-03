import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/drafts/data/draft_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DraftStorage.init();
  runApp(const ProviderScope(child: CipLangApp()));
}
