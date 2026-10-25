import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A reusable Glassmorphism card widget.
///
/// Renders a frosted-glass surface with:
/// - BackdropFilter blur (20–25px)
/// - 15% white fill
/// - 25% white border
/// - Rounded corners (24px)
/// - Subtle shadow
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = AppTheme.kCardRadius,
    this.fillColor = AppTheme.kGlassFill,
    this.borderColor = AppTheme.kGlassBorder,
    this.blur = AppTheme.kBlurSigma,
    this.shadows = AppTheme.kCardShadows,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color fillColor;
  final Color borderColor;
  final double blur;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: 1.0),
              boxShadow: shadows,
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// A section header for glass cards (e.g., "HOURLY FORECAST").
class GlassCardHeader extends StatelessWidget {
  const GlassCardHeader({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xB3FFFFFF)),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
