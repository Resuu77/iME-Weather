import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/weather_model.dart';

/// Central Hive box management service.
///
/// Boxes must be opened before [runApp] is called so that the first frame
/// can read cached data synchronously without an async gap.
class HiveService {
  HiveService._();

  static const String _weatherBoxName = 'weather_cache';
  static const String _settingsBoxName = 'settings';

  static late Box<String> _weatherBox; // store JSON strings
  static late Box<dynamic> _settingsBox;

  // ── Initialization ────────────────────────────────────────────────────────

  static Future<void> openBoxes() async {
    _weatherBox = await Hive.openBox<String>(_weatherBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
  }

  // ── Weather cache ─────────────────────────────────────────────────────────

  static Future<void> cacheWeather(String cityId, WeatherModel model) async {
    final json = jsonEncode(_weatherModelToMap(model));
    await _weatherBox.put(cityId, json);
  }

  static WeatherModel? getCachedWeather(String cityId) {
    final raw = _weatherBox.get(cityId);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return WeatherModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // ── Settings helpers ──────────────────────────────────────────────────────

  static String get selectedLanguage =>
      (_settingsBox.get('language') as String?) ?? 'en';

  static Future<void> setSelectedLanguage(String code) =>
      _settingsBox.put('language', code);

  static String get selectedCityId =>
      (_settingsBox.get('cityId') as String?) ?? 'ashgabat';

  static Future<void> setSelectedCityId(String id) =>
      _settingsBox.put('cityId', id);

  // ── Internal serialization ────────────────────────────────────────────────

  static Map<String, dynamic> _weatherModelToMap(WeatherModel m) => {
        'city': {
          'id': m.cityId,
          'name': {
            'en': m.cityNameEn,
            'ru': m.cityNameRu,
            'tk': m.cityNameTk,
          },
        },
        'timezone': m.timezone,
        'current': m.current.toJson(),
        'hourly': m.hourly.map((e) => e.toJson()).toList(),
        'daily': m.daily.map((e) => e.toJson()).toList(),
        'fetchedAt': m.fetchedAt,
      };
}
