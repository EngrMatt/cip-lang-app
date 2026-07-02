/// App 設定。API 規格見 docs/api.md
class AppConfig {
  AppConfig._();

  /// 測試環境 API（Swagger: https://cip-lang-test-20260624.nfs.tw/docs）
  static const String defaultApiBaseUrl =
      'https://cip-lang-test-20260624.nfs.tw';

  /// 本地開發可覆寫：`flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8280`
  static const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl =>
      _envApiBaseUrl.isNotEmpty ? _envApiBaseUrl : defaultApiBaseUrl;

  static const List<String> recordCategories = [
    '錄音',
    '訪談',
    '歌謠',
    '詞彙',
    '未分類',
  ];
}
