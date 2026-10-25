import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/weather_model.dart';
import '../../core/theme/app_theme.dart';
import 'animated_weather_icon.dart';
import 'glass_card.dart';

/// Horizontal scrollable 24-hour forecast card.
class HourlyForecast extends StatelessWidget {
  const HourlyForecast({
    super.key,
    required this.entries,
    required this.headerLabel,
  });

  final List<HourlyEntry> entries;
  final String headerLabel;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCardHeader(
            icon: Icons.access_time_rounded,
            label: headerLabel,
          ),
          const SizedBox(height: 2),
          const Divider(color: AppTheme.kGlassBorder, height: 16),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _HourlyItem(entry: entry, isNow: index == 0);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyItem extends StatelessWidget {
  const _HourlyItem({required this.entry, required this.isNow});

  final HourlyEntry entry;
  final bool isNow;

  @override
  Widget build(BuildContext context) {
    final time = isNow
        ? 'Now'
        : DateFormat.jm().format(DateTime.parse(entry.time));

    return SizedBox(
      width: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            time,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: isNow ? FontWeight.w700 : FontWeight.w400,
                  color: isNow ? Colors.white : const Color(0xCCFFFFFF),
                ),
            textAlign: TextAlign.center,
          ),
          WeatherIconSmall(weatherCode: entry.weatherCode, size: 24),
          Text(
            '${entry.temperature}°',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
