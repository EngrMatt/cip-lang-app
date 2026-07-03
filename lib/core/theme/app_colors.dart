import 'package:flutter/material.dart';

/// Ethnos & Echo Light（stitch_indigenous_linguistic_field_collector）
abstract final class AppColors {
  static const Color primary = Color(0xFF006D48);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFC8EADB);
  static const Color onPrimaryContainer = Color(0xFF002113);
  static const Color secondary = Color(0xFF006D4A);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF6FFBBE);
  static const Color onSecondaryContainer = Color(0xFF002113);
  static const Color tertiary = Color(0xFF7D5700);
  static const Color tertiaryContainer = Color(0xFFFFDDB8);
  static const Color surface = Color(0xFFFBFDFA);
  static const Color surfaceContainer = Color(0xFFF1F4F1);
  static const Color surfaceContainerLow = Color(0xFFF7F9F7);
  static const Color surfaceContainerHigh = Color(0xFFE7E9E7);
  static const Color surfaceVariant = Color(0xFFDEE5E0);
  static const Color onSurface = Color(0xFF191C1B);
  static const Color onSurfaceVariant = Color(0xFF414845);
  static const Color outline = Color(0xFF717975);
  static const Color outlineVariant = Color(0xFFC1C8C3);
  static const Color error = Color(0xFFBA1A1A);
  static const Color glassTint = Color(0x0A006D48);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF466559), Color(0xFF10B981)],
  );

  static const LinearGradient activeChipGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF006D4A), Color(0xFF10B981)],
  );
}
