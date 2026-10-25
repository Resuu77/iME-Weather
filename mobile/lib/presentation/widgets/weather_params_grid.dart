import 'package:flutter/material.dart';

import '../../core/utils/weather_helpers.dart';
import '../../core/theme/app_theme.dart';
import 'glass_card.dart';

/// 2×2 grid of weather parameter mini-cards.
class WeatherParamsGrid extends StatelessWidget {
  const WeatherParamsGrid({
    super.key,
    required this.uvIndex,
    required this.humidity,
    required this.windSpeed,
    required this.feelsLike,
    required this.labels,
  });

  final double? uvIndex;
  final int humidity;
  final int windSpeed;
  final int feelsLike;
  final WeatherParamLabels labels;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        _ParamCard(
          icon: '☀️',
          label: labels.uvIndex,
          value: uvIndex != null ? uvIndex!.toStringAsFixed(1) : '–',
          subtitle: uvLabel(uvIndex),
          subtitleColor: uvColor(uvIndex),
        ),
        _ParamCard(
          icon: '💧',
          label: labels.humidity,
          value: '$humidity%',
          subtitle: _humidityDesc(humidity),
        ),
        _ParamCard(
          icon: '💨',
          label: labels.wind,
          value: formatWind(windSpeed.toDouble()),
        ),
        _ParamCard(
          icon: '🌡️',
          label: labels.feelsLike,
          value: formatTemp(feelsLike),
        ),
      ],
    );
  }

  static String _humidityDesc(int h) {
    if (h < 30) return 'Low';
    if (h < 60) return 'Comfortable';
    if (h < 80) return 'Humid';
    return 'Very Humid';
  }
}

class WeatherParamLabels {
  const WeatherParamLabels({
    required this.uvIndex,
    required this.humidity,
    required this.wind,
    required this.feelsLike,
  });

  final String uvIndex;
  final String humidity;
  final String wind;
  final String feelsLike;
}

class _ParamCard extends StatelessWidget {
  const _ParamCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.subtitleColor,
  });

  final String icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassCard(
      fillColor: AppTheme.kGlassFillDark,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(
                label.toUpperCase(),
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: theme.textTheme.displaySmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          )),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: subtitleColor ?? const Color(0xB3FFFFFF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
