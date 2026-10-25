import 'package:hive_flutter/hive_flutter.dart';

import 'city_model.dart';

part 'weather_model.g.dart';

// ── HourlyEntry ───────────────────────────────────────────────────────────────

@HiveType(typeId: 1)
class HourlyEntry extends HiveObject {
  HourlyEntry({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });

  @HiveField(0)
  final String time;

  @HiveField(1)
  final int temperature;

  @HiveField(2)
  final int weatherCode;

  factory HourlyEntry.fromJson(Map<String, dynamic> json) => HourlyEntry(
        time: json['time'] as String,
        temperature: (json['temperature'] as num).toInt(),
        weatherCode: (json['weatherCode'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'time': time,
        'temperature': temperature,
        'weatherCode': weatherCode,
      };
}

// ── DailyEntry ────────────────────────────────────────────────────────────────

@HiveType(typeId: 2)
class DailyEntry extends HiveObject {
  DailyEntry({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    this.uvIndexMax,
  });

  @HiveField(0)
  final String date;

  @HiveField(1)
  final int weatherCode;

  @HiveField(2)
  final int tempMax;

  @HiveField(3)
  final int tempMin;

  @HiveField(4)
  final double? uvIndexMax;

  factory DailyEntry.fromJson(Map<String, dynamic> json) => DailyEntry(
        date: json['date'] as String,
        weatherCode: (json['weatherCode'] as num).toInt(),
        tempMax: (json['tempMax'] as num).toInt(),
        tempMin: (json['tempMin'] as num).toInt(),
        uvIndexMax: (json['uvIndexMax'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'weatherCode': weatherCode,
        'tempMax': tempMax,
        'tempMin': tempMin,
        'uvIndexMax': uvIndexMax,
      };
}

// ── CurrentWeather ────────────────────────────────────────────────────────────

@HiveType(typeId: 3)
class CurrentWeather extends HiveObject {
  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.weatherCode,
    required this.isDay,
    required this.time,
  });

  @HiveField(0)
  final int temperature;

  @HiveField(1)
  final int apparentTemperature;

  @HiveField(2)
  final int humidity;

  @HiveField(3)
  final int windSpeed;

  @HiveField(4)
  final int weatherCode;

  @HiveField(5)
  final bool isDay;

  @HiveField(6)
  final String time;

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
        temperature: (json['temperature'] as num).toInt(),
        apparentTemperature: (json['apparentTemperature'] as num).toInt(),
        humidity: (json['humidity'] as num).toInt(),
        windSpeed: (json['windSpeed'] as num).toInt(),
        weatherCode: (json['weatherCode'] as num).toInt(),
        isDay: (json['isDay'] as num) == 1,
        time: json['time'] as String,
      );

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'apparentTemperature': apparentTemperature,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'weatherCode': weatherCode,
        'isDay': isDay ? 1 : 0,
        'time': time,
      };
}

// ── WeatherModel ──────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
class WeatherModel extends HiveObject {
  WeatherModel({
    required this.cityId,
    required this.cityNameEn,
    required this.cityNameRu,
    required this.cityNameTk,
    required this.timezone,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });

  @HiveField(0)
  final String cityId;

  @HiveField(1)
  final String cityNameEn;

  @HiveField(2)
  final String cityNameRu;

  @HiveField(3)
  final String cityNameTk;

  @HiveField(4)
  final String timezone;

  @HiveField(5)
  final CurrentWeather current;

  @HiveField(6)
  final List<HourlyEntry> hourly;

  @HiveField(7)
  final List<DailyEntry> daily;

  @HiveField(8)
  final String fetchedAt;

  /// Returns the localised city name for the given language code.
  String cityName(String langCode) {
    switch (langCode) {
      case 'ru':
        return cityNameRu;
      case 'tk':
        return cityNameTk;
      default:
        return cityNameEn;
    }
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final city = json['city'] as Map<String, dynamic>? ?? {};
    final name = city['name'] as Map<String, dynamic>? ?? {};
    final currentJson = json['current'] as Map<String, dynamic>;
    final hourlyList = (json['hourly'] as List<dynamic>)
        .map((e) => HourlyEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    final dailyList = (json['daily'] as List<dynamic>)
        .map((e) => DailyEntry.fromJson(e as Map<String, dynamic>))
        .toList();

    return WeatherModel(
      cityId: (city['id'] as String?) ?? '',
      cityNameEn: (name['en'] as String?) ?? '',
      cityNameRu: (name['ru'] as String?) ?? '',
      cityNameTk: (name['tk'] as String?) ?? '',
      timezone: (json['timezone'] as String?) ?? 'UTC',
      current: CurrentWeather.fromJson(currentJson),
      hourly: hourlyList,
      daily: dailyList,
      fetchedAt: (json['fetchedAt'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  /// Parses raw JSON directly from Open-Meteo forecast endpoint
  factory WeatherModel.fromOpenMeteoJson({
    required Map<String, dynamic> json,
    required CityModel city,
  }) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final hourlyJson = json['hourly'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};

    final current = CurrentWeather(
      temperature: (currentJson['temperature_2m'] as num?)?.round() ?? 0,
      apparentTemperature:
          (currentJson['apparent_temperature'] as num?)?.round() ?? 0,
      humidity: (currentJson['relative_humidity_2m'] as num?)?.round() ?? 0,
      windSpeed: (currentJson['wind_speed_10m'] as num?)?.round() ?? 0,
      weatherCode: (currentJson['weather_code'] as num?)?.toInt() ?? 0,
      isDay: (currentJson['is_day'] as num?) == 1,
      time: (currentJson['time'] as String?) ??
          DateTime.now().toIso8601String(),
    );

    // Hourly forecast: starting from current hour, take up to 24 hours
    final hourlyTimes = (hourlyJson['time'] as List<dynamic>?) ?? [];
    final hourlyTemps = (hourlyJson['temperature_2m'] as List<dynamic>?) ?? [];
    final hourlyCodes = (hourlyJson['weather_code'] as List<dynamic>?) ?? [];

    int startIndex = 0;
    final currentTimeStr = current.time;
    if (currentTimeStr.isNotEmpty && hourlyTimes.isNotEmpty) {
      final hourPrefix = currentTimeStr.length >= 13
          ? currentTimeStr.substring(0, 13)
          : currentTimeStr;
      final found = hourlyTimes.indexWhere(
        (t) => (t as String).startsWith(hourPrefix),
      );
      if (found != -1) {
        startIndex = found;
      }
    }

    final int available = hourlyTimes.length - startIndex;
    final int count = available > 0 ? (available < 24 ? available : 24) : 0;

    final hourlyList = List.generate(count, (i) {
      final idx = startIndex + i;
      return HourlyEntry(
        time: hourlyTimes[idx] as String,
        temperature: (hourlyTemps[idx] as num?)?.round() ?? 0,
        weatherCode: (hourlyCodes[idx] as num?)?.toInt() ?? 0,
      );
    });

    // Daily forecast: up to 7 days
    final dailyTimes = (dailyJson['time'] as List<dynamic>?) ?? [];
    final dailyCodes = (dailyJson['weather_code'] as List<dynamic>?) ?? [];
    final dailyMax = (dailyJson['temperature_2m_max'] as List<dynamic>?) ?? [];
    final dailyMin = (dailyJson['temperature_2m_min'] as List<dynamic>?) ?? [];
    final dailyUv = (dailyJson['uv_index_max'] as List<dynamic>?) ?? [];

    final dailyCount = dailyTimes.length;
    final dailyList = List.generate(dailyCount, (i) {
      return DailyEntry(
        date: dailyTimes[i] as String,
        weatherCode: (dailyCodes[i] as num?)?.toInt() ?? 0,
        tempMax: (dailyMax[i] as num?)?.round() ?? 0,
        tempMin: (dailyMin[i] as num?)?.round() ?? 0,
        uvIndexMax: (dailyUv[i] as num?)?.toDouble(),
      );
    });

    return WeatherModel(
      cityId: city.id,
      cityNameEn: city.nameEn,
      cityNameRu: city.nameRu,
      cityNameTk: city.nameTk,
      timezone: (json['timezone'] as String?) ?? 'UTC',
      current: current,
      hourly: hourlyList,
      daily: dailyList,
      fetchedAt: DateTime.now().toIso8601String(),
    );
  }
}
