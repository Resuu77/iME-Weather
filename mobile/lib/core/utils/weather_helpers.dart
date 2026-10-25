import 'package:flutter/material.dart';

import '../constants/weather_codes.dart';

/// Maps weather conditions (code + isDay) to a dynamic background gradient.
class WeatherBackground {
  WeatherBackground._();

  /// Returns the list of gradient colors for the given weather conditions.
  static List<Color> gradientColors({
    required int weatherCode,
    required bool isDay,
  }) {
    if (!isDay) {
      // Night variants
      final info = getWeatherInfo(weatherCode);
      switch (info.category) {
        case BackgroundCategory.storm:
          return [const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F3460)];
        case BackgroundCategory.rain:
          return [const Color(0xFF1C2333), const Color(0xFF253048), const Color(0xFF1A2640)];
        case BackgroundCategory.snow:
          return [const Color(0xFF1E2A45), const Color(0xFF2C3E6B), const Color(0xFF1A2540)];
        default:
          // Clear / cloudy night → deep indigo with stars
          return [const Color(0xFF0B0C2A), const Color(0xFF1A1C4B), const Color(0xFF0D1538)];
      }
    }

    // Day variants
    final info = getWeatherInfo(weatherCode);
    switch (info.category) {
      case BackgroundCategory.clearDay:
        // Azure blue with warm top glow
        return [const Color(0xFF74B9E8), const Color(0xFF4A90D9), const Color(0xFF2874C8)];
      case BackgroundCategory.cloudy:
        // Steel grey-blue
        return [const Color(0xFF7B8FA8), const Color(0xFF566C84), const Color(0xFF3D5166)];
      case BackgroundCategory.rain:
        // Dark steel
        return [const Color(0xFF4A5568), const Color(0xFF2D3748), const Color(0xFF1A2232)];
      case BackgroundCategory.snow:
        // Cool white-blue
        return [const Color(0xFFB8CEED), const Color(0xFF8AAEDB), const Color(0xFF6090C0)];
      case BackgroundCategory.storm:
        // Deep purple-grey
        return [const Color(0xFF3D3550), const Color(0xFF2A2340), const Color(0xFF1E1830)];
      case BackgroundCategory.clearNight:
        // Should not reach here during day, fallback
        return [const Color(0xFF4A90D9), const Color(0xFF2874C8), const Color(0xFF1A5AA8)];
    }
  }

  /// Background category adjusted for is_day flag.
  static BackgroundCategory effectiveCategory({
    required int weatherCode,
    required bool isDay,
  }) {
    if (!isDay) return BackgroundCategory.clearNight;
    return getWeatherInfo(weatherCode).category;
  }
}

/// Returns a human-readable UV index label.
String uvLabel(double? uvIndex) {
  if (uvIndex == null) return '–';
  if (uvIndex < 3) return 'Low';
  if (uvIndex < 6) return 'Moderate';
  if (uvIndex < 8) return 'High';
  if (uvIndex < 11) return 'Very High';
  return 'Extreme';
}

Color uvColor(double? uvIndex) {
  if (uvIndex == null) return Colors.grey;
  if (uvIndex < 3) return const Color(0xFF4CAF50);
  if (uvIndex < 6) return const Color(0xFFFFC107);
  if (uvIndex < 8) return const Color(0xFFFF9800);
  if (uvIndex < 11) return const Color(0xFFF44336);
  return const Color(0xFF9C27B0);
}

/// Format wind speed with units label.
String formatWind(double speed) => '${speed.round()} km/h';

/// Format temperature with degree symbol.
String formatTemp(int temp) => '$temp°';
