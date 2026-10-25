import 'package:flutter/material.dart';

import '../../core/constants/weather_codes.dart';

/// Renders the WMO weather code as a large emoji in a styled container.
///
/// Animates scale on first appearance using flutter_animate.
class AnimatedWeatherIcon extends StatelessWidget {
  const AnimatedWeatherIcon({
    super.key,
    required this.weatherCode,
    this.size = 48.0,
    this.animate = true,
  });

  final int weatherCode;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final info = getWeatherInfo(weatherCode);
    final icon = Text(
      info.icon,
      style: TextStyle(fontSize: size * 0.9),
      textAlign: TextAlign.center,
    );

    if (!animate) return icon;

    // Simple fade + scale entrance
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: icon,
    );
  }
}

/// Compact weather icon for use inside cards (no animation).
class WeatherIconSmall extends StatelessWidget {
  const WeatherIconSmall({super.key, required this.weatherCode, this.size = 22});

  final int weatherCode;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      getWeatherInfo(weatherCode).icon,
      style: TextStyle(fontSize: size),
    );
  }
}
