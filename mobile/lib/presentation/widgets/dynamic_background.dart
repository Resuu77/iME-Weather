import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/utils/weather_helpers.dart';
import '../../core/constants/weather_codes.dart';

/// Full-screen animated gradient background that transitions smoothly
/// when the weather condition changes.
///
/// Uses [AnimatedContainer] for implicit gradient animation and an
/// optional star/particle overlay for night skies.
class DynamicBackground extends StatefulWidget {
  const DynamicBackground({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  final int weatherCode;
  final bool isDay;
  final Widget child;

  @override
  State<DynamicBackground> createState() => _DynamicBackgroundState();
}

class _DynamicBackgroundState extends State<DynamicBackground>
    with SingleTickerProviderStateMixin {
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _colors = WeatherBackground.gradientColors(
      weatherCode: widget.weatherCode,
      isDay: widget.isDay,
    );
  }

  @override
  void didUpdateWidget(DynamicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weatherCode != widget.weatherCode ||
        oldWidget.isDay != widget.isDay) {
      setState(() {
        _colors = WeatherBackground.gradientColors(
          weatherCode: widget.weatherCode,
          isDay: widget.isDay,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNight = !widget.isDay;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _colors,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Sun glow for clear day
          if (widget.isDay &&
              getWeatherInfo(widget.weatherCode).category ==
                  BackgroundCategory.clearDay)
            Positioned(
              top: -60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 1200.ms),

          // Stars overlay for night
          if (isNight)
            const Positioned.fill(
              child: _StarField(),
            ),

          // Moon glow for night
          if (isNight)
            Positioned(
              top: 40,
              right: 50,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.12),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 1500.ms),

          // Content
          widget.child,
        ],
      ),
    );
  }
}

/// Simple star field drawn with CustomPaint for night sky effect.
class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(),
    );
  }
}

class _StarPainter extends CustomPainter {
  // Pseudo-random star positions (deterministic for consistent look)
  static const List<(double, double, double)> _stars = [
    (0.05, 0.05, 1.2), (0.15, 0.12, 0.8), (0.25, 0.08, 1.5),
    (0.35, 0.15, 0.9), (0.45, 0.04, 1.3), (0.55, 0.10, 0.7),
    (0.65, 0.07, 1.1), (0.75, 0.14, 0.6), (0.85, 0.03, 1.4),
    (0.92, 0.09, 1.0), (0.10, 0.20, 0.5), (0.30, 0.22, 1.2),
    (0.50, 0.18, 0.8), (0.70, 0.24, 1.3), (0.90, 0.16, 0.9),
    (0.08, 0.30, 1.1), (0.22, 0.35, 0.7), (0.42, 0.28, 1.5),
    (0.60, 0.32, 0.6), (0.78, 0.27, 1.0), (0.95, 0.33, 0.8),
    (0.18, 0.40, 1.2), (0.38, 0.38, 0.9), (0.58, 0.42, 1.4),
    (0.72, 0.36, 0.7), (0.88, 0.41, 1.1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.7);
    for (final (xRatio, yRatio, radius) in _stars) {
      canvas.drawCircle(
        Offset(size.width * xRatio, size.height * yRatio),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
