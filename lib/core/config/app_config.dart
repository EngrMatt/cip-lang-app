import 'dart:io';

/// App 設定。API 規格見 docs/api.md
class AppConfig {
  AppConfig._();

  /// 可透過 `--dart-define=API_BASE_URL=http://192.168.x.x:8280` 覆寫（實機測試）
  static const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_envApiBaseUrl.isNotEmpty) return _envApiBaseUrl;
    if (Platform.isAndroid) return 'http://10.0.2.2:8280';
    return 'http://localhost:8280';
  }

  static const List<String> recordCategories = [
    '錄音',
    '訪談',
    '歌謠',
    '詞彙',
    '未分類',
  ];
}
