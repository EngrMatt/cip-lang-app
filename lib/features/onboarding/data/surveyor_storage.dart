import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/surveyor_profile.dart';

class SurveyorStorage {
  static const _key = 'surveyor_profile';

  static Future<SurveyorProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return SurveyorProfile.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  static Future<void> save(SurveyorProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
