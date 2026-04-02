import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF003FB1);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1A56DB);
  static const Color onPrimaryContainer = Color(0xFFD4DCFF);

  // Secondary
  static const Color secondary = Color(0xFF006C49);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF7EF6BE);
  static const Color onSecondaryContainer = Color(0xFF00714C);

  // Tertiary
  static const Color tertiary = Color(0xFF8A2600);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFB33400);
  static const Color onTertiaryContainer = Color(0xFFFFD4C8);

  // Surface and Background
  static const Color surface = Color(0xFFF9F9FF);
  static const Color onSurface = Color(0xFF141C2B);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F3FF);
  static const Color surfaceContainer = Color(0xFFE8EEFF);
  static const Color surfaceContainerHigh = Color(0xFFE0E8FD);
  static const Color surfaceContainerHighest = Color(0xFFDBE2F8);
  static const Color surfaceVariant = Color(0xFFDBE2F8);
  static const Color onSurfaceVariant = Color(0xFF434654);

  // Outline
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C5D7);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  
  // Custom Splash Gradient (Based on the splash_landing_screen HTML)
  static const LinearGradient splashGradient = LinearGradient(
    colors: [
      Color(0xFF1A56DB), // primary-container
      Color(0xFF0E9F6E), // Greenish tone from the original gradient
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
