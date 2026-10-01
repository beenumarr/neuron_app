import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// NORI logo mark — a soft sheet with a seed resting on its corner.
/// "The food, and the small thing you couldn't see until something
/// looked at it for you.  Two shapes, no outline, no gradient."
class AppLogo extends StatelessWidget {
  final double size;
  final double cornerRadius;
  final bool showShadow;
  final bool useContainer;

  const AppLogo({
    super.key,
    this.size = 100,
    this.cornerRadius = 28,
    this.showShadow = false,
    this.useContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = CustomPaint(
      size: Size(useContainer ? size * 0.72 : size, useContainer ? size * 0.72 : size),
      painter: _NoriLogoPainter(),
    );

    if (!useContainer) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: logoWidget),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(cornerRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.brand.withValues(alpha: 0.16),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Center(child: logoWidget),
    );
  }
}

/// Draws the NORI sheet-and-seed mark.
///
/// Sheet: a rounded rectangle (28 % corner radius) in sage.
/// Seed:  a small circle (42 % of sheet size) in terracotta that overhangs
///        the top-right corner of the sheet.
class _NoriLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final sheetSize = s * 0.72;
    final cornerR = sheetSize * 0.28;
    final seedR = sheetSize * 0.21; // 42 % diameter → 21 % radius

    // Position the sheet centred-left-bottom so the seed can overhang top-right
    final sheetLeft = (s - sheetSize) / 2 - seedR * 0.15;
    final sheetTop = (s - sheetSize) / 2 + seedR * 0.15;

    // Sheet
    final sheetRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(sheetLeft, sheetTop, sheetSize, sheetSize),
      Radius.circular(cornerR),
    );
    canvas.drawRRect(sheetRect, Paint()..color = AppColors.sage);

    // Seed — overhangs the top-right corner of the sheet
    final seedCenter = Offset(
      sheetLeft + sheetSize - cornerR * 0.55,
      sheetTop + cornerR * 0.55,
    );
    canvas.drawCircle(seedCenter, seedR, Paint()..color = AppColors.brand);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
