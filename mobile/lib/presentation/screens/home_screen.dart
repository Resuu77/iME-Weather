import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/weather_codes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/weather_helpers.dart';
import '../../data/models/weather_model.dart';
import '../providers/locale_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/animated_weather_icon.dart';
import '../widgets/daily_forecast.dart';
import '../widgets/dynamic_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/hourly_forecast.dart';
import '../widgets/weather_params_grid.dart';
import 'city_selector_screen.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: weatherAsync.when(
        loading: () => _buildLoadingState(context, l10n),
        error: (err, _) => _buildErrorState(context, ref, l10n, err),
        data: (weather) => _buildWeatherContent(context, ref, weather, l10n, locale),
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  Widget _buildLoadingState(BuildContext context, AppLocalizations l10n) {
    return DynamicBackground(
      weatherCode: 0,
      isDay: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
            const SizedBox(height: 16),
            Text(l10n.loading, style: AppTheme.textTheme.displaySmall),
          ],
        ),
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Object err,
  ) {
    return DynamicBackground(
      weatherCode: 3,
      isDay: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                l10n.noInternet,
                style: AppTheme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => ref.read(weatherProvider.notifier).refresh(),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(l10n.errorRetry,
                      style: AppTheme.textTheme.bodyLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Main content ─────────────────────────────────────────────────────────

  Widget _buildWeatherContent(
    BuildContext context,
    WidgetRef ref,
    WeatherModel weather,
    AppLocalizations l10n,
    Locale locale,
  ) {
    final current = weather.current;
    final langCode = locale.languageCode;
    final cityName = weather.cityName(langCode);
    final weatherInfo = getWeatherInfo(current.weatherCode);
    final weatherLabel = _resolveWmoLabel(l10n, weatherInfo.labelKey);
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return DynamicBackground(
      weatherCode: current.weatherCode,
      isDay: current.isDay,
      child: RefreshIndicator(
        onRefresh: () => ref.read(weatherProvider.notifier).refresh(),
        color: Colors.white,
        backgroundColor: Colors.white24,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── App bar with city selector ──────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 0,
              floating: true,
              pinned: false,
              actions: [
                // Language switcher
                _LanguageSwitcher(l10n: l10n),
                // City selector button
                IconButton(
                  icon: const Icon(Icons.location_city_rounded, color: Colors.white),
                  onPressed: () => _openCitySelector(context, ref),
                  tooltip: l10n.citySelector,
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 8,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero header ─────────────────────────────────────
                    _HeroHeader(
                      cityName: cityName,
                      temperature: current.temperature,
                      weatherLabel: weatherLabel,
                      tempMax: today?.tempMax,
                      tempMin: today?.tempMin,
                      weatherCode: current.weatherCode,
                    ),

                    const SizedBox(height: 28),

                    // ── Hourly forecast ──────────────────────────────────
                    HourlyForecast(
                      entries: weather.hourly,
                      headerLabel: l10n.sectionHourly,
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.15),

                    const SizedBox(height: 16),

                    // ── 7-day forecast ───────────────────────────────────
                    DailyForecast(
                      entries: weather.daily,
                      headerLabel: l10n.sectionDaily,
                      languageCode: langCode,
                      getDayLabel: (date, isFirst) =>
                          _getDayLabel(l10n, date, isFirst, langCode),
                      getWmoLabel: (code) =>
                          _resolveWmoLabel(l10n, getWeatherInfo(code).labelKey),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),

                    const SizedBox(height: 16),

                    // ── Details grid ─────────────────────────────────────
                    WeatherParamsGrid(
                      uvIndex: today?.uvIndexMax,
                      humidity: current.humidity,
                      windSpeed: current.windSpeed,
                      feelsLike: current.apparentTemperature,
                      labels: WeatherParamLabels(
                        uvIndex: l10n.labelUvIndex,
                        humidity: l10n.labelHumidity,
                        wind: l10n.labelWind,
                        feelsLike: l10n.labelFeelsLike,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),

                    // ── Offline notice ───────────────────────────────────
                    const SizedBox(height: 16),
                    _OfflineNotice(fetchedAt: weather.fetchedAt, l10n: l10n),

                    // Safe area bottom padding
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _openCitySelector(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const CitySelectorScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// Resolves a WMO label key to the localised string via AppLocalizations.
  static String _resolveWmoLabel(AppLocalizations l10n, String key) {
    // Use a switch to map each labelKey to the generated getter
    switch (key) {
      case 'wmo_0': return l10n.wmo_0;
      case 'wmo_1': return l10n.wmo_1;
      case 'wmo_2': return l10n.wmo_2;
      case 'wmo_3': return l10n.wmo_3;
      case 'wmo_45': return l10n.wmo_45;
      case 'wmo_48': return l10n.wmo_48;
      case 'wmo_51': return l10n.wmo_51;
      case 'wmo_53': return l10n.wmo_53;
      case 'wmo_55': return l10n.wmo_55;
      case 'wmo_61': return l10n.wmo_61;
      case 'wmo_63': return l10n.wmo_63;
      case 'wmo_65': return l10n.wmo_65;
      case 'wmo_71': return l10n.wmo_71;
      case 'wmo_73': return l10n.wmo_73;
      case 'wmo_75': return l10n.wmo_75;
      case 'wmo_77': return l10n.wmo_77;
      case 'wmo_80': return l10n.wmo_80;
      case 'wmo_81': return l10n.wmo_81;
      case 'wmo_82': return l10n.wmo_82;
      case 'wmo_85': return l10n.wmo_85;
      case 'wmo_86': return l10n.wmo_86;
      case 'wmo_95': return l10n.wmo_95;
      case 'wmo_96': return l10n.wmo_96;
      case 'wmo_99': return l10n.wmo_99;
      default: return l10n.wmo_unknown;
    }
  }

  static String _getDayLabel(
    AppLocalizations l10n,
    String dateStr,
    bool isFirst,
    String langCode,
  ) {
    if (isFirst) return l10n.dayToday;
    final date = DateTime.parse(dateStr);
    switch (date.weekday) {
      case DateTime.monday: return l10n.dayMon;
      case DateTime.tuesday: return l10n.dayTue;
      case DateTime.wednesday: return l10n.dayWed;
      case DateTime.thursday: return l10n.dayThu;
      case DateTime.friday: return l10n.dayFri;
      case DateTime.saturday: return l10n.daySat;
      default: return l10n.daySun;
    }
  }
}

// ── Hero header widget ────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.cityName,
    required this.temperature,
    required this.weatherLabel,
    required this.tempMax,
    required this.tempMin,
    required this.weatherCode,
  });

  final String cityName;
  final int temperature;
  final String weatherLabel;
  final int? tempMax;
  final int? tempMin;
  final int weatherCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // City name
        Text(
          cityName,
          style: Theme.of(context).textTheme.displayMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 600.ms),

        const SizedBox(height: 4),

        // Large temperature + icon side by side
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$temperature°',
              style: Theme.of(context).textTheme.displayLarge,
            ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.85, 0.85)),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: AnimatedWeatherIcon(weatherCode: weatherCode, size: 56),
            ),
          ],
        ),

        // Weather label
        Text(
          weatherLabel,
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 6),

        // Max / Min
        if (tempMax != null && tempMin != null)
          Text(
            'H:${tempMax}°  L:${tempMin}°',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
          ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }
}

// ── Language switcher ─────────────────────────────────────────────────────────

class _LanguageSwitcher extends ConsumerWidget {
  const _LanguageSwitcher({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final langs = ['en', 'ru', 'tk'];
    final labels = {'en': 'EN', 'ru': 'RU', 'tk': 'TK'};

    return PopupMenuButton<String>(
      icon: Text(
        labels[locale.languageCode] ?? 'EN',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      color: const Color(0xFF1A2640),
      onSelected: (code) =>
          ref.read(localeProvider.notifier).setLocale(code),
      itemBuilder: (_) => langs.map((code) {
        return PopupMenuItem(
          value: code,
          child: Row(
            children: [
              if (locale.languageCode == code)
                const Icon(Icons.check, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(labels[code]!,
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Offline notice ────────────────────────────────────────────────────────────

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice({required this.fetchedAt, required this.l10n});

  final String fetchedAt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().difference(DateTime.parse(fetchedAt));
    if (age.inMinutes < 60) return const SizedBox.shrink();

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.offlineNotice,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
