import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant {
  /// .p1 { background: var(--teal); color: #fff }
  primary,

  /// .p2 { background: var(--mint); color: var(--teal) }
  secondary,

  /// .p3 { border: 1.5px solid var(--teal); color: var(--ink); background: transparent }
  outline,

  /// Ghost transparent
  ghost,

  /// Coral danger
  danger,
}

/// Nori Brand Guidelines v2 Button.
///
/// "Pills for actions, 48px minimum touch targets, thin 1px borders instead of heavy shadows."
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonVariant variant;
  final dynamic icon; // Supports either Widget or IconData
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? textColor;

  const AppButton({
    super.key,
    String? text,
    String? title,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.height = 50,
    this.width,
    this.borderRadius,
    this.borderColor,
    this.textColor,
  }) : text = text ?? title ?? '';

  const AppButton.secondary({
    super.key,
    String? text,
    String? title,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 50,
    this.width,
    this.borderRadius,
    this.borderColor,
    this.textColor,
  })  : variant = AppButtonVariant.secondary,
        text = text ?? title ?? '';

  const AppButton.outline({
    super.key,
    String? text,
    String? title,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 50,
    this.width,
    this.borderRadius,
    this.borderColor,
    this.textColor,
  })  : variant = AppButtonVariant.outline,
        text = text ?? title ?? '';

  const AppButton.danger({
    super.key,
    String? text,
    String? title,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 50,
    this.width,
    this.borderRadius,
    this.borderColor,
    this.textColor,
  })  : variant = AppButtonVariant.danger,
        text = text ?? title ?? '';

  const AppButton.ghost({
    super.key,
    String? text,
    String? title,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 50,
    this.width,
    this.borderRadius,
    this.borderColor,
    this.textColor,
  })  : variant = AppButtonVariant.ghost,
        text = text ?? title ?? '';

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
    // Pill shape: 999px radius (or half height)
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(widget.height / 2);
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final textStyle = _buildTextStyle(isEnabled);

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
                        : AppColors.teal,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    widget.icon is IconData
                        ? Icon(
                            widget.icon as IconData,
                            size: 18,
                            color: textStyle.color,
                          )
                        : (widget.icon as Widget),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: textStyle,
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
          color: isEnabled ? AppColors.teal : AppColors.teal.withValues(alpha: 0.45),
          borderRadius: radius,
          boxShadow: isEnabled ? AppShadows.primaryButton : [],
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: isEnabled ? AppColors.mint : AppColors.mint.withValues(alpha: 0.5),
          borderRadius: radius,
        );
      case AppButtonVariant.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: radius,
          border: Border.all(
            color: widget.borderColor ?? (isEnabled ? AppColors.teal : AppColors.line),
            width: 1.5,
          ),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: radius,
        );
      case AppButtonVariant.danger:
        return BoxDecoration(
          color: isEnabled ? AppColors.coral : AppColors.coral.withValues(alpha: 0.5),
          borderRadius: radius,
          boxShadow: isEnabled ? AppShadows.dangerButton : [],
        );
    }
  }

  TextStyle _buildTextStyle(bool isEnabled) {
    if (widget.textColor != null) {
      return AppTypography.button.copyWith(
        color: isEnabled ? widget.textColor : AppColors.textMuted,
      );
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return AppTypography.button;
      case AppButtonVariant.secondary:
        return AppTypography.buttonSecondary.copyWith(
          color: isEnabled ? AppColors.teal : AppColors.textMuted,
        );
      case AppButtonVariant.outline:
        return AppTypography.buttonSecondary.copyWith(
          color: isEnabled ? AppColors.ink : AppColors.textMuted,
        );
      case AppButtonVariant.ghost:
        return AppTypography.subtitle.copyWith(
          color: isEnabled ? AppColors.teal : AppColors.textMuted,
          fontWeight: FontWeight.w600,
        );
      case AppButtonVariant.danger:
        return AppTypography.button;
    }
  }
}
