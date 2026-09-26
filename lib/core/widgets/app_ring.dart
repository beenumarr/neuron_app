import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
    this.color = AppColors.brand,
    this.trackColor = const Color(0x2218B97A),
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
