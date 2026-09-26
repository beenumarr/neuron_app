import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

// ── Welcome Illustration ──────────────────────────────────────────────────────
class WelcomeIllustrationWidget extends StatefulWidget {
  final double width;
  final double height;

  const WelcomeIllustrationWidget({
    super.key,
    this.width = 320,
    this.height = 240,
  });

  @override
  State<WelcomeIllustrationWidget> createState() => _WelcomeIllustrationWidgetState();
}

class _WelcomeIllustrationWidgetState extends State<WelcomeIllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy = sin(_controller.value * 2 * pi) * 6.0;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _WelcomeIllustrationPainter(),
      ),
    );
  }
}

class _WelcomeIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 320.0;
    final center = Offset(size.width / 2, size.height / 2);

    // Glowing Concentric Circles
    final aura1 = Paint()..color = AppColors.brandLight;
    canvas.drawCircle(center, 105 * s, aura1);

    final aura2 = Paint()..color = const Color(0x105E6CFF);
    canvas.drawCircle(center, 75 * s, aura2);

    // Floating Phone Card
    final phoneShadow = Paint()
      ..color = const Color(0x200F172A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 72 * s, height: 126 * s),
      Radius.circular(16 * s),
    );
    canvas.drawRRect(phoneRect.shift(Offset(0, 8 * s)), phoneShadow);

    final phonePaint = Paint()..color = Colors.white;
    canvas.drawRRect(phoneRect, phonePaint);

    // Phone Header Pill
    final pillPaint = Paint()..color = AppColors.brandLight;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 26 * s, center.dy - 50 * s, 52 * s, 7 * s),
        Radius.circular(3.5 * s),
      ),
      pillPaint,
    );

    // Ring on Phone
    final ringCenter = Offset(center.dx, center.dy - 6 * s);
    final ringRadius = 18 * s;
    final ringTrack = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5 * s;
    canvas.drawCircle(ringCenter, ringRadius, ringTrack);

    final ringProgress = Paint()
      ..color = AppColors.brand
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5 * s
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: ringCenter, radius: ringRadius),
      -pi / 2,
      4.2,
      false,
      ringProgress,
    );

    final ringInner = Paint()..color = AppColors.brandLight;
    canvas.drawCircle(ringCenter, 8 * s, ringInner);

    // Macro Bars on Phone
    final barW = 10 * s;
    final bY = center.dy + 26 * s;
    final b1 = Paint()..color = AppColors.brand;
    final b2 = Paint()..color = AppColors.indigo;
    final b3 = Paint()..color = AppColors.orange;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 20 * s, bY + 4 * s, barW, 16 * s), Radius.circular(3 * s)), b1);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 5 * s, bY - 3 * s, barW, 23 * s), Radius.circular(3 * s)), b2);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx + 10 * s, bY, barW, 20 * s), Radius.circular(3 * s)), b3);

    // Left Floating Card
    final leftCardShadow = Paint()
      ..color = const Color(0x180F172A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final leftCardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(24 * s, center.dy - 35 * s, 76 * s, 34 * s),
      Radius.circular(12 * s),
    );
    canvas.drawRRect(leftCardRect.shift(Offset(0, 4 * s)), leftCardShadow);
    canvas.drawRRect(leftCardRect, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(40 * s, center.dy - 18 * s), 7 * s, Paint()..color = AppColors.brandLight);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(52 * s, center.dy - 24 * s, 36 * s, 5 * s), Radius.circular(2.5 * s)), Paint()..color = AppColors.border);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(52 * s, center.dy - 15 * s, 22 * s, 5 * s), Radius.circular(2.5 * s)), Paint()..color = AppColors.brand.withValues(alpha: 0.6));

    // Right Floating Card
    final rightCardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(220 * s, center.dy - 15 * s, 76 * s, 34 * s),
      Radius.circular(12 * s),
    );
    canvas.drawRRect(rightCardRect.shift(Offset(0, 4 * s)), leftCardShadow);
    canvas.drawRRect(rightCardRect, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(236 * s, center.dy + 2 * s), 7 * s, Paint()..color = AppColors.indigoLight);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(248 * s, center.dy - 4 * s, 36 * s, 5 * s), Radius.circular(2.5 * s)), Paint()..color = AppColors.border);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(248 * s, center.dy + 5 * s, 22 * s, 5 * s), Radius.circular(2.5 * s)), Paint()..color = AppColors.indigo.withValues(alpha: 0.6));

    // Decorative floating dots
    canvas.drawCircle(Offset(72 * s, center.dy + 65 * s), 6 * s, Paint()..color = AppColors.brand.withValues(alpha: 0.3));
    canvas.drawCircle(Offset(250 * s, center.dy - 60 * s), 8 * s, Paint()..color = AppColors.indigo.withValues(alpha: 0.25));
    canvas.drawCircle(Offset(260 * s, center.dy + 60 * s), 5 * s, Paint()..color = AppColors.orange.withValues(alpha: 0.3));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Onboarding Illustrations (Steps 0, 1, 2, 3) ───────────────────────────────
class OnboardingIllustrationWidget extends StatefulWidget {
  final int step;
  final double width;
  final double height;

  const OnboardingIllustrationWidget({
    super.key,
    required this.step,
    this.width = 280,
    this.height = 240,
  });

  @override
  State<OnboardingIllustrationWidget> createState() => _OnboardingIllustrationWidgetState();
}

class _OnboardingIllustrationWidgetState extends State<OnboardingIllustrationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        final dy = sin(_anim.value * 2 * pi) * 5.0;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _OnboardingStepPainter(step: widget.step),
      ),
    );
  }
}

class _OnboardingStepPainter extends CustomPainter {
  final int step;

  _OnboardingStepPainter({required this.step});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 280.0;
    final center = Offset(size.width / 2, size.height / 2);

    if (step == 0) {
      _paintStep0(canvas, size, center, s);
    } else if (step == 1) {
      _paintStep1(canvas, size, center, s);
    } else if (step == 2) {
      _paintStep2(canvas, size, center, s);
    } else {
      _paintStep3(canvas, size, center, s);
    }
  }

  void _paintStep0(Canvas canvas, Size size, Offset center, double s) {
    // Halo
    canvas.drawCircle(center, 95 * s, Paint()..color = AppColors.brandLight);
    canvas.drawCircle(center, 65 * s, Paint()..color = Colors.white.withValues(alpha: 0.7));

    // Heart Path
    final heartPath = Path();
    final hX = center.dx;
    final hY = center.dy + 8 * s;
    heartPath.moveTo(hX, hY + 36 * s);
    heartPath.cubicTo(hX - 45 * s, hY + 12 * s, hX - 55 * s, hY - 24 * s, hX - 35 * s, hY - 38 * s);
    heartPath.cubicTo(hX - 22 * s, hY - 48 * s, hX - 5 * s, hY - 42 * s, hX, hY - 28 * s);
    heartPath.cubicTo(hX + 5 * s, hY - 42 * s, hX + 22 * s, hY - 48 * s, hX + 35 * s, hY - 38 * s);
    heartPath.cubicTo(hX + 55 * s, hY - 24 * s, hX + 45 * s, hY + 12 * s, hX, hY + 36 * s);
    heartPath.close();

    final heartPaint = Paint()
      ..color = AppColors.brand
      ..style = PaintingStyle.fill;
    canvas.drawPath(heartPath, heartPaint);

    // EKG Wave
    final ekgPath = Path()
      ..moveTo(center.dx - 60 * s, center.dy + 2 * s)
      ..lineTo(center.dx - 40 * s, center.dy + 2 * s)
      ..lineTo(center.dx - 32 * s, center.dy - 18 * s)
      ..lineTo(center.dx - 24 * s, center.dy + 22 * s)
      ..lineTo(center.dx - 16 * s, center.dy - 10 * s)
      ..lineTo(center.dx - 8 * s, center.dy + 2 * s)
      ..lineTo(center.dx + 20 * s, center.dy + 2 * s)
      ..lineTo(center.dx + 28 * s, center.dy - 14 * s)
      ..lineTo(center.dx + 36 * s, center.dy + 18 * s)
      ..lineTo(center.dx + 44 * s, center.dy + 2 * s)
      ..lineTo(center.dx + 60 * s, center.dy + 2 * s);

    final ekgPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.8 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(ekgPath, ekgPaint);

    // Floating Chips
    final shadow = Paint()
      ..color = const Color(0x150F172A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // Left Chip
    final leftRect = RRect.fromRectAndRadius(Rect.fromLTWH(18 * s, center.dy - 55 * s, 60 * s, 26 * s), Radius.circular(9 * s));
    canvas.drawRRect(leftRect.shift(Offset(0, 3 * s)), shadow);
    canvas.drawRRect(leftRect, Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(24 * s, center.dy - 49 * s, 12 * s, 14 * s), Radius.circular(4 * s)), Paint()..color = AppColors.brandLight);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(40 * s, center.dy - 49 * s, 26 * s, 4 * s), Radius.circular(2 * s)), Paint()..color = AppColors.border);

    // Right Chip
    final rightRect = RRect.fromRectAndRadius(Rect.fromLTWH(202 * s, center.dy - 45 * s, 60 * s, 26 * s), Radius.circular(9 * s));
    canvas.drawRRect(rightRect.shift(Offset(0, 3 * s)), shadow);
    canvas.drawRRect(rightRect, Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(208 * s, center.dy - 39 * s, 12 * s, 14 * s), Radius.circular(4 * s)), Paint()..color = AppColors.indigoLight);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(224 * s, center.dy - 39 * s, 26 * s, 4 * s), Radius.circular(2 * s)), Paint()..color = AppColors.border);
  }

  void _paintStep1(Canvas canvas, Size size, Offset center, double s) {
    // Aura
    canvas.drawCircle(center, 95 * s, Paint()..color = const Color(0x185E6CFF));

    // Dark sleek phone
    final phoneShadow = Paint()
      ..color = const Color(0x350F172A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    final phoneOuter = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 94 * s, height: 154 * s),
      Radius.circular(18 * s),
    );
    canvas.drawRRect(phoneOuter.shift(Offset(0, 8 * s)), phoneShadow);
    canvas.drawRRect(phoneOuter, Paint()..color = const Color(0xFF1E293B));

    final phoneInner = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 80 * s, height: 136 * s),
      Radius.circular(12 * s),
    );
    canvas.drawRRect(phoneInner, Paint()..color = const Color(0xFF0F172A));

    // Scanning brackets
    final bracketPaint = Paint()
      ..color = AppColors.brand
      ..strokeWidth = 2.5 * s
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final bL = center.dx - 26 * s;
    final bR = center.dx + 26 * s;
    final bT = center.dy - 38 * s;
    final bB = center.dy + 38 * s;
    final arm = 10 * s;

    // Top-left
    canvas.drawLine(Offset(bL, bT), Offset(bL + arm, bT), bracketPaint);
    canvas.drawLine(Offset(bL, bT), Offset(bL, bT + arm), bracketPaint);
    // Top-right
    canvas.drawLine(Offset(bR, bT), Offset(bR - arm, bT), bracketPaint);
    canvas.drawLine(Offset(bR, bT), Offset(bR, bT + arm), bracketPaint);
    // Bottom-left
    canvas.drawLine(Offset(bL, bB), Offset(bL + arm, bB), bracketPaint);
    canvas.drawLine(Offset(bL, bB), Offset(bL, bB - arm), bracketPaint);
    // Bottom-right
    canvas.drawLine(Offset(bR, bB), Offset(bR - arm, bB), bracketPaint);
    canvas.drawLine(Offset(bR, bB), Offset(bR, bB - arm), bracketPaint);

    // Glowing scan laser beam
    final laserGlow = Paint()
      ..color = AppColors.brand.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRect(Rect.fromLTWH(center.dx - 40 * s, center.dy - 1 * s, 80 * s, 3 * s), laserGlow);
    canvas.drawRect(Rect.fromLTWH(center.dx - 40 * s, center.dy, 80 * s, 2 * s), Paint()..color = AppColors.brand);

    // Food target placeholder boxes
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 14 * s, center.dy - 26 * s, 28 * s, 18 * s), Radius.circular(5 * s)), Paint()..color = const Color(0x40F5A524));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 14 * s, center.dy + 12 * s, 28 * s, 18 * s), Radius.circular(5 * s)), Paint()..color = const Color(0x4018B97A));

    // Floating result card
    final resCardShadow = Paint()
      ..color = const Color(0x180F172A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final resCard = RRect.fromRectAndRadius(Rect.fromLTWH(24 * s, center.dy + 25 * s, 72 * s, 44 * s), Radius.circular(12 * s));
    canvas.drawRRect(resCard.shift(Offset(0, 4 * s)), resCardShadow);
    canvas.drawRRect(resCard, Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(32 * s, center.dy + 33 * s, 24 * s, 4 * s), Radius.circular(2 * s)), Paint()..color = AppColors.border);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(32 * s, center.dy + 41 * s, 48 * s, 5 * s), Radius.circular(2.5 * s)), Paint()..color = AppColors.brand.withValues(alpha: 0.8));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(32 * s, center.dy + 50 * s, 34 * s, 4 * s), Radius.circular(2 * s)), Paint()..color = AppColors.border);
  }

  void _paintStep2(Canvas canvas, Size size, Offset center, double s) {
    // Aura
    canvas.drawCircle(center, 95 * s, Paint()..color = const Color(0x148B5CF6));

    // AI Speech Bubble (White surface)
    final shadow = Paint()
      ..color = const Color(0x180F172A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final aiBubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(42 * s, center.dy - 60 * s, 140 * s, 54 * s),
      Radius.circular(18 * s),
    );
    canvas.drawRRect(aiBubble.shift(Offset(0, 4 * s)), shadow);
    canvas.drawRRect(aiBubble, Paint()..color = Colors.white);

    // AI Bubble Avatar (Gradient Zap)
    final avCenter = Offset(66 * s, center.dy - 33 * s);
    canvas.drawCircle(avCenter, 14 * s, Paint()..color = AppColors.brand);
    final zapPath = Path()
      ..moveTo(avCenter.dx - 2 * s, avCenter.dy - 7 * s)
      ..lineTo(avCenter.dx - 5 * s, avCenter.dy)
      ..lineTo(avCenter.dx + 1 * s, avCenter.dy)
      ..lineTo(avCenter.dx - 3 * s, avCenter.dy + 7 * s)
      ..lineTo(avCenter.dx + 5 * s, avCenter.dy - 1 * s)
      ..lineTo(avCenter.dx, avCenter.dy - 1 * s)
      ..close();
    canvas.drawPath(zapPath, Paint()..color = Colors.white);

    // Message preview lines inside AI Bubble
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(88 * s, center.dy - 45 * s, 76 * s, 5 * s), Radius.circular(2.5 * s)), Paint()..color = AppColors.border);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(88 * s, center.dy - 35 * s, 58 * s, 5 * s), Radius.circular(2.5 * s)), Paint()..color = AppColors.brandLight);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(88 * s, center.dy - 25 * s, 66 * s, 5 * s), Radius.circular(2.5 * s)), Paint()..color = AppColors.border);

    // User Message Bubble (Emerald surface)
    final userBubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(100 * s, center.dy + 15 * s, 136 * s, 42 * s),
      Radius.circular(18 * s),
    );
    final userShadow = Paint()
      ..color = const Color(0x3518B97A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(userBubble.shift(Offset(0, 4 * s)), userShadow);
    canvas.drawRRect(userBubble, Paint()..color = AppColors.brand);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(114 * s, center.dy + 26 * s, 85 * s, 5 * s), Radius.circular(2.5 * s)), Paint()..color = Colors.white.withValues(alpha: 0.8));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(114 * s, center.dy + 36 * s, 60 * s, 5 * s), Radius.circular(2.5 * s)), Paint()..color = Colors.white.withValues(alpha: 0.5));

    // Animated Typing dots
    canvas.drawCircle(Offset(54 * s, center.dy + 72 * s), 4 * s, Paint()..color = AppColors.textMuted.withValues(alpha: 0.6));
    canvas.drawCircle(Offset(68 * s, center.dy + 72 * s), 4 * s, Paint()..color = AppColors.textMuted.withValues(alpha: 0.4));
    canvas.drawCircle(Offset(82 * s, center.dy + 72 * s), 4 * s, Paint()..color = AppColors.textMuted.withValues(alpha: 0.25));
  }

  void _paintStep3(Canvas canvas, Size size, Offset center, double s) {
    // Aura
    canvas.drawCircle(center, 95 * s, Paint()..color = const Color(0x18F5A524));

    // Main Health Score Ring (Center)
    final ringCenter = Offset(center.dx, center.dy - 18 * s);
    final rR = 48 * s;

    // Track
    canvas.drawCircle(ringCenter, rR, Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9 * s);

    // Progress Arc (87%)
    canvas.drawArc(
      Rect.fromCircle(center: ringCenter, radius: rR),
      -pi / 2,
      2 * pi * 0.87,
      false,
      Paint()
        ..color = AppColors.brand
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9 * s
        ..strokeCap = StrokeCap.round,
    );

    // Center circular badge with drop shadow
    final centerCard = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(ringCenter + Offset(0, 3 * s), 34 * s, centerCard);
    canvas.drawCircle(ringCenter, 34 * s, Paint()..color = Colors.white);

    // Text: 87 / Health Score
    final textPainter87 = TextPainter(
      text: TextSpan(
        text: '87',
        style: AppTypography.heading1.copyWith(
          fontSize: 20 * s,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter87.paint(canvas, ringCenter - Offset(textPainter87.width / 2, 16 * s));

    final textPainterSub = TextPainter(
      text: TextSpan(
        text: 'Health Score',
        style: AppTypography.caption.copyWith(
          fontSize: 8.5 * s,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainterSub.paint(canvas, ringCenter - Offset(textPainterSub.width / 2, -5 * s));

    // Mini Left Ring (Indigo)
    final leftCenter = Offset(62 * s, center.dy - 18 * s);
    canvas.drawCircle(leftCenter, 20 * s, Paint()..color = AppColors.border..style = PaintingStyle.stroke..strokeWidth = 4.5 * s);
    canvas.drawArc(Rect.fromCircle(center: leftCenter, radius: 20 * s), -pi / 2, 4.0, false, Paint()..color = AppColors.indigo..style = PaintingStyle.stroke..strokeWidth = 4.5 * s..strokeCap = StrokeCap.round);

    // Mini Right Ring (Orange)
    final rightCenter = Offset(218 * s, center.dy - 18 * s);
    canvas.drawCircle(rightCenter, 20 * s, Paint()..color = AppColors.border..style = PaintingStyle.stroke..strokeWidth = 4.5 * s);
    canvas.drawArc(Rect.fromCircle(center: rightCenter, radius: 20 * s), -pi / 2, 5.0, false, Paint()..color = AppColors.orange..style = PaintingStyle.stroke..strokeWidth = 4.5 * s..strokeCap = StrokeCap.round);

    // Weekly Bar Chart Histogram at bottom
    final barHeights = [20.0, 30.0, 24.0, 36.0, 28.0, 32.0, 42.0];
    for (int i = 0; i < 7; i++) {
      final bX = 76 * s + i * 18 * s;
      final h = barHeights[i] * s;
      final bY = center.dy + 75 * s - h;
      final isLast = i == 6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(bX, bY, 11 * s, h), Radius.circular(3 * s)),
        Paint()..color = isLast ? AppColors.brand : AppColors.border,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingStepPainter oldDelegate) => oldDelegate.step != step;
}

// ── Email Illustration ────────────────────────────────────────────────────────
class EmailIllustrationWidget extends StatelessWidget {
  final double size;

  const EmailIllustrationWidget({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.9),
      painter: _EmailIllustrationPainter(),
    );
  }
}

class _EmailIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 200.0;
    final center = Offset(size.width / 2, size.height / 2);

    // Halo
    canvas.drawCircle(center, 78 * s, Paint()..color = AppColors.brandLight);

    // Envelope card
    final shadow = Paint()
      ..color = const Color(0x200F172A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    final envRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 128 * s, height: 90 * s),
      Radius.circular(16 * s),
    );
    canvas.drawRRect(envRect.shift(Offset(0, 6 * s)), shadow);
    canvas.drawRRect(envRect, Paint()..color = Colors.white);

    // Flap V Line
    final flapPath = Path()
      ..moveTo(center.dx - 64 * s, center.dy - 25 * s)
      ..lineTo(center.dx, center.dy + 12 * s)
      ..lineTo(center.dx + 64 * s, center.dy - 25 * s);
    canvas.drawPath(
      flapPath,
      Paint()
        ..color = AppColors.border
        ..strokeWidth = 2 * s
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Circular @ badge
    final badgeCenter = Offset(center.dx, center.dy + 8 * s);
    canvas.drawCircle(badgeCenter, 18 * s, Paint()..color = AppColors.brand..style = PaintingStyle.stroke..strokeWidth = 2.5 * s);
    canvas.drawCircle(badgeCenter, 9 * s, Paint()..color = AppColors.brandLight);

    final atPainter = TextPainter(
      text: TextSpan(
        text: '@',
        style: TextStyle(
          fontSize: 18 * s,
          fontWeight: FontWeight.w700,
          color: AppColors.brand,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    atPainter.paint(canvas, badgeCenter - Offset(atPainter.width / 2, atPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Shield Illustration (Forgot Password) ─────────────────────────────────────
class ShieldIllustrationWidget extends StatelessWidget {
  final double size;

  const ShieldIllustrationWidget({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.9),
      painter: _ShieldIllustrationPainter(),
    );
  }
}

class _ShieldIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 200.0;
    final center = Offset(size.width / 2, size.height / 2);

    // Halo
    canvas.drawCircle(center, 78 * s, Paint()..color = AppColors.indigoLight);

    // Shield Path
    final shield = Path()
      ..moveTo(center.dx, center.dy - 60 * s)
      ..lineTo(center.dx + 52 * s, center.dy - 36 * s)
      ..lineTo(center.dx + 52 * s, center.dy + 12 * s)
      ..cubicTo(center.dx + 52 * s, center.dy + 44 * s, center.dx + 28 * s, center.dy + 68 * s, center.dx, center.dy + 76 * s)
      ..cubicTo(center.dx - 28 * s, center.dy + 68 * s, center.dx - 52 * s, center.dy + 44 * s, center.dx - 52 * s, center.dy + 12 * s)
      ..lineTo(center.dx - 52 * s, center.dy - 36 * s)
      ..close();

    final shadow = Paint()
      ..color = const Color(0x200F172A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(shield.shift(Offset(0, 6 * s)), shadow);
    canvas.drawPath(shield, Paint()..color = Colors.white);

    // Inner Shield Accent
    final innerShield = Path()
      ..moveTo(center.dx, center.dy - 50 * s)
      ..lineTo(center.dx + 42 * s, center.dy - 30 * s)
      ..lineTo(center.dx + 42 * s, center.dy + 12 * s)
      ..cubicTo(center.dx + 42 * s, center.dy + 38 * s, center.dx + 24 * s, center.dy + 58 * s, center.dx, center.dy + 66 * s)
      ..cubicTo(center.dx - 24 * s, center.dy + 58 * s, center.dx - 42 * s, center.dy + 38 * s, center.dx - 42 * s, center.dy + 12 * s)
      ..lineTo(center.dx - 42 * s, center.dy - 30 * s)
      ..close();
    canvas.drawPath(innerShield, Paint()..color = AppColors.indigoLight);

    // Lock Body
    final lockRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 14 * s), width: 34 * s, height: 26 * s),
      Radius.circular(8 * s),
    );
    canvas.drawRRect(lockRect, Paint()..color = AppColors.indigo);

    // Lock Shackle
    final shackle = Path()
      ..moveTo(center.dx - 10 * s, center.dy + 2 * s)
      ..lineTo(center.dx - 10 * s, center.dy - 7 * s)
      ..cubicTo(center.dx - 10 * s, center.dy - 17 * s, center.dx + 10 * s, center.dy - 17 * s, center.dx + 10 * s, center.dy - 7 * s)
      ..lineTo(center.dx + 10 * s, center.dy + 2 * s);
    canvas.drawPath(
      shackle,
      Paint()
        ..color = AppColors.indigo
        ..strokeWidth = 3.5 * s
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Keyhole
    canvas.drawCircle(Offset(center.dx, center.dy + 11 * s), 3 * s, Paint()..color = Colors.white);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(center.dx - 1.5 * s, center.dy + 11 * s, 3 * s, 6 * s), Radius.circular(1.5 * s)), Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Success Checkmark (Pulsing Green Checkmark) ───────────────────────────────
class SuccessCheckmarkWidget extends StatefulWidget {
  final double size;

  const SuccessCheckmarkWidget({super.key, this.size = 112});

  @override
  State<SuccessCheckmarkWidget> createState() => _SuccessCheckmarkWidgetState();
}

class _SuccessCheckmarkWidgetState extends State<SuccessCheckmarkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brand.withValues(alpha: _pulseAnimation.value),
          ),
          alignment: Alignment.center,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size * 0.72,
              height: widget.size * 0.72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x5518B97A),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
