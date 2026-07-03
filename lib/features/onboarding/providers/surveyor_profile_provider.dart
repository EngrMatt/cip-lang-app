import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/surveyor_storage.dart';
import '../models/surveyor_profile.dart';

final surveyorProfileProvider =
    AsyncNotifierProvider<SurveyorProfileNotifier, SurveyorProfile?>(
  SurveyorProfileNotifier.new,
);

class SurveyorProfileNotifier extends AsyncNotifier<SurveyorProfile?> {
  @override
  Future<SurveyorProfile?> build() => SurveyorStorage.load();

  Future<void> save(SurveyorProfile profile) async {
    await SurveyorStorage.save(profile);
    state = AsyncData(profile);
  }

  Future<void> clear() async {
    await SurveyorStorage.clear();
    state = const AsyncData(null);
  }
}
