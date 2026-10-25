import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/city_model.dart';
import '../models/weather_model.dart';
import '../local/hive_service.dart';
import '../../core/constants/api.dart';

class WeatherRepository {
  WeatherRepository({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Fetch weather for [city].
  ///
  /// Strategy:
  /// 1. If [kUseDirectOpenMeteo] == true (default):
  ///    Calls Open-Meteo API directly without needing any backend server.
  /// 2. If [kUseDirectOpenMeteo] == false:
  ///    Calls the custom backend proxy at [kWeatherProxyEndpoint].
  /// 3. On success → persists to Hive offline cache and returns fresh data.
  /// 4. On network error / offline → returns cached data from Hive if available.
  Future<WeatherModel> getWeather(CityModel city) async {
    try {
      final WeatherModel model;
      if (kUseDirectOpenMeteo) {
        model = await _fetchDirectFromOpenMeteo(city);
      } else {
        model = await _fetchFromBackendProxy(city);
      }

      // Persist to Hive for offline use
      await HiveService.cacheWeather(city.id, model);
      return model;
    } catch (e) {
      // Offline fallback: serve from local Hive cache if available
      final cached = HiveService.getCachedWeather(city.id);
      if (cached != null) return cached;
      rethrow;
    }
  }

  /// Fetch weather directly from Open-Meteo (zero backend dependency)
  Future<WeatherModel> _fetchDirectFromOpenMeteo(CityModel city) async {
    final uri = Uri.parse(kOpenMeteoForecastEndpoint).replace(
      queryParameters: {
        'latitude': city.lat.toString(),
        'longitude': city.lon.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m',
        'hourly': 'temperature_2m,weather_code',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,uv_index_max',
        'wind_speed_unit': 'kmh',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(kRequestTimeout);

    if (response.statusCode != 200) {
      throw HttpException(
        'Open-Meteo API returned ${response.statusCode}: ${response.body}',
      );
    }

    final rawJson = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherModel.fromOpenMeteoJson(
      json: rawJson,
      city: city,
    );
  }

  /// Fetch weather through custom backend proxy (when VPS is deployed)
  Future<WeatherModel> _fetchFromBackendProxy(CityModel city) async {
    final Map<String, String> queryParams = city.id.startsWith('gps_')
        ? {'lat': city.lat.toString(), 'lon': city.lon.toString()}
        : {'city': city.id};

    final uri = Uri.parse(kWeatherProxyEndpoint).replace(
      queryParameters: queryParams,
    );

    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(kRequestTimeout);

    if (response.statusCode != 200) {
      throw HttpException(
        'Proxy API returned ${response.statusCode}: ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherModel.fromJson(json);
  }

  /// Fetch weather by raw coordinates (used for GPS location).
  Future<WeatherModel> getWeatherByCoords({
    required double lat,
    required double lon,
    required String cityId,
    CityModel? city,
  }) async {
    final effectiveCity = city ??
        CityModel.fromGps(
          lat: lat,
          lon: lon,
        );
    return getWeather(effectiveCity);
  }
}
