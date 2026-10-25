import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/local/hive_service.dart';
import '../../data/models/city_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../cities/turkmenistan_cities.dart';

// ── Repository provider ───────────────────────────────────────────────────────

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepository();
});

// ── Selected city provider ────────────────────────────────────────────────────

final selectedCityProvider =
    StateNotifierProvider<CityNotifier, CityModel>((ref) {
  return CityNotifier();
});

class CityNotifier extends StateNotifier<CityModel> {
  CityNotifier()
      : super(
          kTurkmenistanCities.firstWhere(
            (c) => c.id == HiveService.selectedCityId,
            orElse: () => kTurkmenistanCities.first,
          ),
        );

  void selectCity(CityModel city) {
    state = city;
    HiveService.setSelectedCityId(city.id);
  }

  /// Try to detect GPS location and set a virtual GPS city.
  Future<void> detectGpsCity() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();

    final gpsCity = CityModel.fromGps(
      lat: position.latitude,
      lon: position.longitude,
    );
    state = gpsCity;
    HiveService.setSelectedCityId(gpsCity.id);
  }
}

// ── Weather data provider ─────────────────────────────────────────────────────

final weatherProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherModel>(WeatherNotifier.new);

class WeatherNotifier extends AsyncNotifier<WeatherModel> {
  @override
  Future<WeatherModel> build() async {
    final city = ref.watch(selectedCityProvider);
    return _fetchWeather(city);
  }

  Future<WeatherModel> _fetchWeather(CityModel city) async {
    final repo = ref.read(weatherRepositoryProvider);

    // Show cached data instantly while fetching
    final cached = HiveService.getCachedWeather(city.id);
    if (cached != null && state is! AsyncLoading) {
      // Return cache, then schedule background refresh
      Future.microtask(() => _backgroundRefresh(city));
      return cached;
    }

    if (city.id.startsWith('gps_')) {
      return repo.getWeatherByCoords(
        lat: city.lat,
        lon: city.lon,
        cityId: city.id,
        city: city,
      );
    }
    return repo.getWeather(city);
  }

  Future<void> _backgroundRefresh(CityModel city) async {
    try {
      final repo = ref.read(weatherRepositoryProvider);
      final fresh = city.id.startsWith('gps_')
          ? await repo.getWeatherByCoords(
              lat: city.lat,
              lon: city.lon,
              cityId: city.id,
              city: city,
            )
          : await repo.getWeather(city);
      state = AsyncData(fresh);
    } catch (_) {
      // Silent fail — keep showing cached data
    }
  }

  /// Public method to trigger a manual refresh.
  Future<void> refresh() async {
    final city = ref.read(selectedCityProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchWeather(city));
  }
}
