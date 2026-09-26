import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.06),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardFloating = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.10),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> primaryButton = [
    BoxShadow(
      color: Color(0x3D18B97A), // 24% brand
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> logoGlow = [
    BoxShadow(
      color: Color(0x4418B97A),
      blurRadius: 48,
      offset: Offset(0, 16),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> softInput = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.03),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
}
