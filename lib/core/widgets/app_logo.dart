import 'package:flutter/material.dart';

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
    final imageWidget = Image.asset(
      'assets/images/logo_emblem.png',
      width: useContainer ? size * 0.72 : size,
      height: useContainer ? size * 0.72 : size,
      fit: BoxFit.contain,
    );

    if (!useContainer) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: imageWidget),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cornerRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.16),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Center(child: imageWidget),
    );
  }
}
