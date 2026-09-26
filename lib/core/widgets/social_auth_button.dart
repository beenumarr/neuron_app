import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SocialAuthButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  const SocialAuthButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  factory SocialAuthButton.google({VoidCallback? onPressed}) {
    return SocialAuthButton(
      label: 'Google',
      onPressed: onPressed,
      icon: CustomPaint(
        size: const Size(18, 18),
        painter: _GoogleIconPainter(),
      ),
    );
  }

  factory SocialAuthButton.apple({VoidCallback? onPressed}) {
    return SocialAuthButton(
      label: 'Apple',
      onPressed: onPressed,
      icon: const Icon(
        Icons.apple,
        size: 20,
        color: AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.backgroundCard,
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodyBold.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 18.0;

    // Blue
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    final bluePath = Path()
      ..moveTo(17.64 * s, 9.2 * s)
      ..cubicTo(17.64 * s, 8.56 * s, 17.58 * s, 7.95 * s, 17.48 * s, 7.36 * s)
      ..lineTo(9.0 * s, 7.36 * s)
      ..lineTo(9.0 * s, 10.84 * s)
      ..lineTo(13.84 * s, 10.84 * s)
      ..cubicTo(13.63 * s, 11.97 * s, 13.0 * s, 12.92 * s, 12.05 * s, 13.56 * s)
      ..lineTo(14.96 * s, 15.82 * s)
      ..cubicTo(16.66 * s, 14.25 * s, 17.64 * s, 11.94 * s, 17.64 * s, 9.2 * s)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Green
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final greenPath = Path()
      ..moveTo(9.0 * s, 18.0 * s)
      ..cubicTo(11.43 * s, 18.0 * s, 13.47 * s, 17.19 * s, 14.96 * s, 15.82 * s)
      ..lineTo(12.05 * s, 13.56 * s)
      ..cubicTo(11.24 * s, 14.1 * s, 10.21 * s, 14.42 * s, 9.0 * s, 14.42 * s)
      ..cubicTo(6.66 * s, 14.42 * s, 4.67 * s, 12.84 * s, 3.96 * s, 10.71 * s)
      ..lineTo(0.96 * s, 13.04 * s)
      ..cubicTo(2.44 * s, 15.98 * s, 5.48 * s, 18.0 * s, 9.0 * s, 18.0 * s)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Yellow
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final yellowPath = Path()
      ..moveTo(3.96 * s, 10.71 * s)
      ..cubicTo(3.78 * s, 10.17 * s, 3.68 * s, 9.59 * s, 3.68 * s, 9.0 * s)
      ..cubicTo(3.68 * s, 8.41 * s, 3.78 * s, 7.83 * s, 3.96 * s, 7.29 * s)
      ..lineTo(0.96 * s, 4.96 * s)
      ..cubicTo(0.35 * s, 6.17 * s, 0.0 * s, 7.55 * s, 0.0 * s, 9.0 * s)
      ..cubicTo(0.0 * s, 10.45 * s, 0.35 * s, 11.83 * s, 0.96 * s, 13.04 * s)
      ..lineTo(3.96 * s, 10.71 * s)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Red
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final redPath = Path()
      ..moveTo(9.0 * s, 3.58 * s)
      ..cubicTo(10.32 * s, 3.58 * s, 11.51 * s, 4.03 * s, 12.44 * s, 4.93 * s)
      ..lineTo(15.02 * s, 2.35 * s)
      ..cubicTo(13.46 * s, 0.89 * s, 11.43 * s, 0.0 * s, 9.0 * s, 0.0 * s)
      ..cubicTo(5.48 * s, 0.0 * s, 2.44 * s, 2.02 * s, 0.96 * s, 4.96 * s)
      ..lineTo(3.96 * s, 7.29 * s)
      ..cubicTo(4.67 * s, 5.16 * s, 6.66 * s, 3.58 * s, 9.0 * s, 3.58 * s)
      ..close();
    canvas.drawPath(redPath, redPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
