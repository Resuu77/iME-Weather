import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cities/turkmenistan_cities.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/city_model.dart';
import '../providers/locale_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/dynamic_background.dart';
import '../widgets/glass_card.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CitySelectorScreen extends ConsumerStatefulWidget {
  const CitySelectorScreen({super.key});

  @override
  ConsumerState<CitySelectorScreen> createState() => _CitySelectorScreenState();
}

class _CitySelectorScreenState extends ConsumerState<CitySelectorScreen> {
  bool _detectingGps = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: DynamicBackground(
        weatherCode: 1,
        isDay: true,
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: GlassCard(
                        padding: const EdgeInsets.all(10),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.citySelector,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── GPS button ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: _detectingGps ? null : () => _detectGps(context),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _detectingGps
                              ? l10n.fetchingLocation
                              : l10n.myLocation,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      if (_detectingGps)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
            ),

            const SizedBox(height: 8),

            // ── Divider ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Divider(color: Color(0x40FFFFFF), height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'TURKMENISTAN',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Color(0x40FFFFFF), height: 1),
                  ),
                ],
              ),
            ),

            // ── City list ────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: kTurkmenistanCities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final city = kTurkmenistanCities[index];
                  final isSelected = city.id == selectedCity.id;

                  return GestureDetector(
                    onTap: () => _selectCity(city),
                    child: _CityTile(
                      city: city,
                      isSelected: isSelected,
                      langCode: locale.languageCode,
                    ),
                  ).animate(delay: (index * 40).ms).fadeIn().slideX(begin: 0.1);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _detectGps(BuildContext context) async {
    setState(() => _detectingGps = true);
    try {
      await ref.read(selectedCityProvider.notifier).detectGpsCity();
      await ref.read(weatherProvider.notifier).refresh();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.locationPermissionDenied),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _detectingGps = false);
    }
  }

  void _selectCity(CityModel city) {
    ref.read(selectedCityProvider.notifier).selectCity(city);
    ref.read(weatherProvider.notifier).refresh();
    Navigator.of(context).pop();
  }
}

class _CityTile extends StatelessWidget {
  const _CityTile({
    required this.city,
    required this.isSelected,
    required this.langCode,
  });

  final CityModel city;
  final bool isSelected;
  final String langCode;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      fillColor: isSelected
          ? const Color(0x44FFFFFF) // brighter when selected
          : AppTheme.kGlassFill,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          const Text('📍', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city.name(langCode),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${city.lat.toStringAsFixed(2)}°N, ${city.lon.toStringAsFixed(2)}°E',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
        ],
      ),
    );
  }
}
