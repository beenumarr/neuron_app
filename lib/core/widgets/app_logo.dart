import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double cornerRadius;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 96,
    this.cornerRadius = 32,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final scale = size / 96.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.logoGradient,
        borderRadius: BorderRadius.circular(cornerRadius * scale),
        boxShadow: showShadow ? AppShadows.logoGlow : null,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(44 * scale, 44 * scale),
          painter: _LogoMarkPainter(),
        ),
      ),
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 44.0;

    final strokePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(8 * s, 34 * s)
      ..lineTo(8 * s, 14 * s)
      ..lineTo(20 * s, 28 * s)
      ..lineTo(22 * s, 22 * s)
      ..lineTo(34 * s, 34 * s);

    canvas.drawPath(path, strokePaint);

    final auraPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(22 * s, 13 * s), 5 * s, auraPaint);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(22 * s, 13 * s), 3 * s, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
