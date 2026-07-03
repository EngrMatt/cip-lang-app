import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/create/presentation/create_hub_page.dart';
import '../../features/explore/presentation/explore_page.dart';
import '../../features/onboarding/presentation/checkin_page.dart';
import '../../features/onboarding/providers/surveyor_profile_provider.dart';
import '../../features/records/presentation/create_record_page.dart';
import '../../features/records/presentation/record_detail_page.dart';
import '../../features/records/presentation/record_list_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../presentation/main_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authProvider);
  final profileAsync = ref.watch(surveyorProfileProvider);

  return GoRouter(
    initialLocation: '/records',
    redirect: (context, state) {
      if (authAsync.isLoading || profileAsync.isLoading) return null;

      final isLoggedIn = authAsync.valueOrNull ?? false;
      final hasProfile = profileAsync.valueOrNull != null;
      final loc = state.matchedLocation;

      final isLogin = loc == '/login';
      final isCheckin = loc == '/checkin';
      final isFullscreenWizard = loc.startsWith('/records/new');
      final isDetail = RegExp(r'^/records/\d+').hasMatch(loc);

      if (!isLoggedIn && !isLogin) return '/login';
      if (isLoggedIn && isLogin) {
        return hasProfile ? '/records' : '/checkin';
      }
      if (isLoggedIn && !hasProfile && !isCheckin && !isFullscreenWizard) {
        return '/checkin';
      }
      if (isDetail || isFullscreenWizard || isCheckin || isLogin) {
        return null;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/checkin',
        builder: (context, state) => const CheckinPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/records',
                builder: (context, state) => const RecordListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                builder: (context, state) => const CreateHubPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExplorePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/records/new',
        builder: (context, state) {
          final draftId = state.uri.queryParameters['draft'];
          return CreateRecordPage(draftId: draftId);
        },
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
