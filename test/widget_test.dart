import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cip_lang_app/app.dart';
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
        ],
        child: const CipLangApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('語料列表'), findsOneWidget);
  });
}

class _MockRecordsListNotifier extends RecordsListNotifier {
  _MockRecordsListNotifier(this._response);

  final RecordListResponse _response;

  @override
  Future<RecordListResponse> build() async => _response;
}
