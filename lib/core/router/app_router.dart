import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/records/presentation/create_record_page.dart';
import '../../features/records/presentation/record_detail_page.dart';
import '../../features/records/presentation/record_list_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const RecordListPage(),
      ),
      GoRoute(
        path: '/records/new',
        builder: (context, state) => const CreateRecordPage(),
      ),
      GoRoute(
        path: '/records/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return RecordDetailPage(recordId: id);
        },
      ),
    ],
  );
});
