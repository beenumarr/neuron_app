import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum NoriLogoVariant {
  /// Symbol with rounded Deep Teal container, Mint leaf, Teal heartbeat, Amber node
  contained,

  /// Standalone Nori Green leaf, White heartbeat, Amber node (transparent background)
  standalone,

  /// Standalone for dark backgrounds
  standaloneOnDark,
}

/// Nori Brand Guidelines v2 Logo.
///
/// "The symbol is a leaf carrying a heartbeat, with an amber AI node at its tip.
/// Three ideas live in one mark: a leaf (nutrition, farming, nori itself),
/// a pulse line (clinical care, health data) and a single amber node (the AI that notices)."
class AppLogo extends StatelessWidget {
  final double size;
  final NoriLogoVariant variant;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 64,
    this.variant = NoriLogoVariant.contained,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _NoriV2LogoPainter(
          variant: variant,
          showShadow: showShadow,
        ),
      ),
    );
  }
}

/// Full brand lockup: Symbol + "nori" wordmark in Sora ExtraBold all-lowercase.
class NoriBrandLockup extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color? textColor;
  final NoriLogoVariant logoVariant;
  final double spacing;

  const NoriBrandLockup({
    super.key,
    this.iconSize = 44,
    this.fontSize = 32,
    this.textColor,
    this.logoVariant = NoriLogoVariant.contained,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppLogo(size: iconSize, variant: logoVariant),
        SizedBox(width: spacing),
        Text(
          'nori',
          style: GoogleFonts.sora(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.02 * fontSize,
            color: textColor ?? AppColors.ink,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

/// Exact vector painter for Nori v2 symbol from SVG paths.
class _NoriV2LogoPainter extends CustomPainter {
  final NoriLogoVariant variant;
  final bool showShadow;

  _NoriV2LogoPainter({
    required this.variant,
    required this.showShadow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / 64.0;
    canvas.save();
    canvas.scale(scale, scale);

    if (variant == NoriLogoVariant.contained) {
      _paintContainedSymbol(canvas);
    } else {
      _paintStandaloneSymbol(canvas, onDark: variant == NoriLogoVariant.standaloneOnDark);
    }

    canvas.restore();
  }

  void _paintContainedSymbol(Canvas canvas) {
    // 1. Container: 64x64, rx=18, fill=#0B4F4A
    final containerRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 64, 64),
      const Radius.circular(18),
    );

    if (showShadow) {
      final shadowPaint = Paint()
        ..color = AppColors.teal.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(containerRect.shift(const Offset(0, 4)), shadowPaint);
    }

    final containerPaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.fill;
    canvas.drawRRect(containerRect, containerPaint);

    // 2. Leaf path: M32 11C48 13 53 30 46 43 40 53 25 53 18 46 13 32 19 16 32 11Z fill=#DDF4EA
    final leafPath = Path()
      ..moveTo(32, 11)
      ..cubicTo(48, 13, 53, 30, 46, 43)
      ..cubicTo(40, 53, 25, 53, 18, 46)
      ..cubicTo(13, 32, 19, 16, 32, 11)
      ..close();

    final leafPaint = Paint()
      ..color = AppColors.mint
      ..style = PaintingStyle.fill;
    canvas.drawPath(leafPath, leafPaint);

    // 3. Heartbeat pulse line: M17 35h9l4-9 5 17 4-8h9 stroke=#0B4F4A stroke-width=3.2
    final pulsePath = Path()
      ..moveTo(17, 35)
      ..lineTo(26, 35)
      ..lineTo(30, 26)
      ..lineTo(35, 43)
      ..lineTo(39, 35)
      ..lineTo(48, 35);

    final pulsePaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pulsePath, pulsePaint);

    // 4. Amber AI node: circle cx=48 cy=16 r=5.5 fill=#F2A93B
    final amberPaint = Paint()
      ..color = AppColors.amber
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(48, 16), 5.5, amberPaint);
  }

  void _paintStandaloneSymbol(Canvas canvas, {required bool onDark}) {
    // Leaf path: M32 6C50 8 56 28 48 43 41 56 23 56 14 48 8 31 16 12 32 6Z fill=#16A37F
    final leafPath = Path()
      ..moveTo(32, 6)
      ..cubicTo(50, 8, 56, 28, 48, 43)
      ..cubicTo(41, 56, 23, 56, 14, 48)
      ..cubicTo(8, 31, 16, 12, 32, 6)
      ..close();

    final leafPaint = Paint()
      ..color = AppColors.green
      ..style = PaintingStyle.fill;
    canvas.drawPath(leafPath, leafPaint);

    // Pulse line: M13 35h10l5-10 6 19 5-9h11 stroke=#fff stroke-width=3.6
    final pulsePath = Path()
      ..moveTo(13, 35)
      ..lineTo(23, 35)
      ..lineTo(28, 25)
      ..lineTo(34, 44)
      ..lineTo(39, 35)
      ..lineTo(50, 35);

    final pulsePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(pulsePath, pulsePaint);

    // Amber AI node: circle cx=52 cy=11 r=6 fill=#F2A93B
    final amberPaint = Paint()
      ..color = AppColors.amber
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(52, 11), 6.0, amberPaint);
  }

  @override
  bool shouldRepaint(covariant _NoriV2LogoPainter oldDelegate) =>
      oldDelegate.variant != variant || oldDelegate.showShadow != showShadow;
}
