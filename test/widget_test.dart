import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cip_lang_app/app.dart';
import 'package:cip_lang_app/features/auth/providers/auth_provider.dart';
import 'package:cip_lang_app/features/onboarding/models/parsed_record_note.dart';
import 'package:cip_lang_app/features/onboarding/models/surveyor_profile.dart';
import 'package:cip_lang_app/features/onboarding/providers/surveyor_profile_provider.dart';
import 'package:cip_lang_app/features/records/providers/records_providers.dart';
import 'package:cip_lang_app/models/record.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final mockResponse = RecordListResponse(
      items: const [],
      total: 0,
      page: 1,
      pageSize: 20,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          recordsListProvider.overrideWith(() => _MockRecordsListNotifier(mockResponse)),
          surveyorProfileProvider.overrideWith(
            () => _MockSurveyorProfileNotifier(
              const SurveyorProfile(name: '測試員'),
            ),
          ),
          authProvider.overrideWith(() => _MockAuthNotifier()),
        ],
        child: const CipLangApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('文化語料資料庫'), findsOneWidget);
  });

  test('mergeNoteWithSurveyorPrefix injects profile prefix', () {
    const profile = SurveyorProfile(name: '王小明', region: '花蓮');
    expect(
      mergeNoteWithSurveyorPrefix(profile: profile, userNote: '田野備註'),
      '[調查員: 王小明 | 花蓮] 田野備註',
    );
    expect(
      mergeNoteWithSurveyorPrefix(profile: profile),
      '[調查員: 王小明 | 花蓮]',
    );
  });

  test('ParsedRecordNote parses surveyor prefix', () {
    final parsed = ParsedRecordNote.parse('[調查員: 陳建名 | 鳳山區] 測試');
    expect(parsed.surveyorName, '陳建名');
    expect(parsed.region, '鳳山區');
    expect(parsed.userNote, '測試');
  });

  test('ParsedRecordNote falls back to plain note', () {
    final parsed = ParsedRecordNote.parse('一般備註');
    expect(parsed.surveyorName, isNull);
    expect(parsed.userNote, '一般備註');
  });
}

class _MockRecordsListNotifier extends RecordsListNotifier {
  _MockRecordsListNotifier(this._response);

  final RecordListResponse _response;

  @override
  Future<RecordListResponse> build() async => _response;
}

class _MockSurveyorProfileNotifier extends SurveyorProfileNotifier {
  _MockSurveyorProfileNotifier(this._profile);

  final SurveyorProfile? _profile;

  @override
  Future<SurveyorProfile?> build() async => _profile;
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<bool> build() async => true;
}
