import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// NORI brand progress ring — defaults to sage with warm track.
class AppRing extends StatelessWidget {
  final double value;
  final double max;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final Widget? child;

  const AppRing({
    super.key,
    required this.value,
    this.max = 100,
    this.size = 96,
    this.strokeWidth = 7,
    this.color = AppColors.sage,
    this.trackColor = const Color(0x227A8A5E),
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              value: value,
              max: max,
              strokeWidth: strokeWidth,
              color: color,
              trackColor: trackColor,
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double max;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.value,
    required this.max,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc
    final sweepAngle = 2 * pi * (value / max).clamp(0.0, 1.0);
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.max != max ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}

class MacroRing extends StatelessWidget {
  final String label;
  final num value;
  final String unit;
  final Color color;
  final int pct;

  const MacroRing({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
    required this.color,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppRing(
          value: pct.toDouble(),
          max: 100,
          size: 56,
          strokeWidth: 5,
          color: color,
          trackColor: color.withValues(alpha: 0.14),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label == 'Calories' ? '$value' : '$value$unit',
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
