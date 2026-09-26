import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonVariant variant;
  final Widget? icon;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.height = 54,
    this.width,
    this.borderRadius,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.02,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(18);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Widget content = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: Container(
        height: widget.height,
        width: widget.isFullWidth ? double.infinity : widget.width,
        decoration: _buildDecoration(effectiveRadius, isEnabled),
        alignment: Alignment.center,
        child: widget.isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.variant == AppButtonVariant.primary
                        ? AppColors.textWhite
                        : AppColors.brand,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: _buildTextStyle(isEnabled),
                  ),
                ],
              ),
      ),
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isEnabled ? widget.onPressed : null,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }

  BoxDecoration _buildDecoration(BorderRadius radius, bool isEnabled) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          gradient: isEnabled
              ? AppColors.primaryGradient
              : LinearGradient(
                  colors: [
                    AppColors.brand.withValues(alpha: 0.5),
                    AppColors.brandDark.withValues(alpha: 0.5),
                  ],
                ),
          borderRadius: radius,
          boxShadow: isEnabled ? AppShadows.primaryButton : [],
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: radius,
          border: Border.all(color: AppColors.border, width: 1.5),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: radius,
        );
      case AppButtonVariant.danger:
        return BoxDecoration(
          color: AppColors.danger,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
    }
  }

  TextStyle _buildTextStyle(bool isEnabled) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return AppTypography.button;
      case AppButtonVariant.secondary:
        return AppTypography.button.copyWith(
          color: isEnabled ? AppColors.textPrimary : AppColors.textMuted,
        );
      case AppButtonVariant.ghost:
        return AppTypography.subtitle.copyWith(
          color: isEnabled ? AppColors.textSecondary : AppColors.textMuted,
          fontWeight: FontWeight.w600,
        );
      case AppButtonVariant.danger:
        return AppTypography.button;
    }
  }
}
