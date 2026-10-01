import 'package:flutter/material.dart';

/// Nori Brand Guidelines v2 Shadows.
///
/// Guidelines state: "thin 1px borders instead of heavy shadows".
/// Shadows are subtle, soft, and non-colored.
class AppShadows {
  /// Subtle card shadow (used alongside thin 1px line border)
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A0A2E2C), // 4% ink
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  /// Floating card / modal shadow
  static const List<BoxShadow> cardFloating = [
    BoxShadow(
      color: Color(0x120A2E2C), // 7% ink
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Subtle primary button shadow
  static const List<BoxShadow> primaryButton = [
    BoxShadow(
      color: Color(0x280B4F4A), // 16% deep teal
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Soft input shadow
  static const List<BoxShadow> softInput = [
    BoxShadow(
      color: Color(0x060A2E2C),
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Danger button shadow
  static const List<BoxShadow> dangerButton = [
    BoxShadow(
      color: Color(0x28E5604D),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}
