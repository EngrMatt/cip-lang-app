import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/records/data/record_repository.dart';
import '../../features/records/providers/records_providers.dart';
import '../network/dio_client.dart';
import 'api_settings_storage.dart';
import 'app_config.dart';

final apiBaseUrlProvider =
    AsyncNotifierProvider<ApiBaseUrlNotifier, String>(ApiBaseUrlNotifier.new);

class ApiBaseUrlNotifier extends AsyncNotifier<String> {
  @override
  Future<String> build() => ApiSettingsStorage.getBaseUrl();

  Future<void> save(String url) async {
    final normalized = ApiSettingsStorage.normalizeUrl(url);
    if (normalized.isEmpty) {
      throw ArgumentError('請輸入 API 網址');
    }
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      throw ArgumentError('網址需以 http:// 或 https:// 開頭');
    }
    await ApiSettingsStorage.setBaseUrl(normalized);
    state = AsyncData(normalized);
    _refreshNetwork();
  }

  Future<void> resetToDefault() async {
    await ApiSettingsStorage.clear();
    state = const AsyncData(AppConfig.defaultApiBaseUrl);
    _refreshNetwork();
  }

  void _refreshNetwork() {
    ref.invalidate(dioProvider);
    ref.invalidate(recordRepositoryProvider);
    ref.invalidate(recordsListProvider);
  }
}
