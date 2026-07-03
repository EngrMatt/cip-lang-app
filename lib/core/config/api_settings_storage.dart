import 'package:shared_preferences/shared_preferences.dart';

import 'app_config.dart';

class ApiSettingsStorage {
  static const _key = 'api_base_url';

  static String normalizeUrl(String url) {
    return url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null && stored.isNotEmpty) {
      return normalizeUrl(stored);
    }
    return AppConfig.defaultApiBaseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, normalizeUrl(url));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
