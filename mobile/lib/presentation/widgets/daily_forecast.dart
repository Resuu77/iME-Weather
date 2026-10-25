import 'package:flutter/material.dart';

import '../../data/models/weather_model.dart';
import '../../core/theme/app_theme.dart';
import 'animated_weather_icon.dart';
import 'glass_card.dart';

/// 7-day daily forecast card with iOS-style min/max temperature bar.
class DailyForecast extends StatelessWidget {
  const DailyForecast({
    super.key,
    required this.entries,
    required this.headerLabel,
    required this.languageCode,
    required this.getDayLabel,
    required this.getWmoLabel,
  });

  final List<DailyEntry> entries;
  final String headerLabel;
  final String languageCode;
  final String Function(String date, bool isFirst) getDayLabel;
  final String Function(int code) getWmoLabel;

  @override
  Widget build(BuildContext context) {
    // Determine overall temperature range across all days for relative bar sizing
    final allMax = entries.map((e) => e.tempMax).reduce((a, b) => a > b ? a : b);
    final allMin = entries.map((e) => e.tempMin).reduce((a, b) => a < b ? a : b);
    final range = (allMax - allMin).toDouble();

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCardHeader(
            icon: Icons.calendar_today_rounded,
            label: headerLabel,
          ),
          const SizedBox(height: 2),
          const Divider(color: AppTheme.kGlassBorder, height: 16),
          ...entries.asMap().entries.map(
            (entry) => _DailyRow(
              daily: entry.value,
              isFirst: entry.key == 0,
              allMin: allMin,
              range: range,
              getDayLabel: getDayLabel,
              getWmoLabel: getWmoLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  const _DailyRow({
    required this.daily,
    required this.isFirst,
    required this.allMin,
    required this.range,
    required this.getDayLabel,
    required this.getWmoLabel,
  });

  final DailyEntry daily;
  final bool isFirst;
  final int allMin;
  final double range;
  final String Function(String date, bool isFirst) getDayLabel;
  final String Function(int code) getWmoLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabel = getDayLabel(daily.date, isFirst);

    // Bar positioning: fraction of total temp range
    final barStart = range > 0 ? (daily.tempMin - allMin) / range : 0.0;
    final barEnd = range > 0 ? (daily.tempMax - allMin) / range : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 48,
            child: Text(
              dayLabel,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isFirst ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          // Weather icon
          WeatherIconSmall(weatherCode: daily.weatherCode, size: 20),
          const SizedBox(width: 8),
          // Min temp
          SizedBox(
            width: 32,
            child: Text(
              '${daily.tempMin}°',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          // Temperature bar
          Expanded(
            child: _TemperatureBar(start: barStart, end: barEnd),
          ),
          const SizedBox(width: 8),
          // Max temp
          SizedBox(
            width: 32,
            child: Text(
              '${daily.tempMax}°',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal gradient bar showing relative temperature range.
class _TemperatureBar extends StatelessWidget {
  const _TemperatureBar({required this.start, required this.end});

  final double start;
  final double end;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final leftPad = totalWidth * start;
        final barWidth = totalWidth * (end - start);

        return SizedBox(
          height: 6,
          child: Stack(
            children: [
              // Track
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Fill
              Positioned(
                left: leftPad,
                child: Container(
                  width: barWidth.clamp(6.0, totalWidth),
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF56CCF2), Color(0xFFEB6534)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
