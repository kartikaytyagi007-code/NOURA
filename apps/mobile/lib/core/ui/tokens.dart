import 'package:flutter/material.dart';

/// Design tokens transcribed from the Stitch "Vitality Editorial" export (light theme).
/// They are the single source for colors, type, spacing and radii, so the final Stitch screens
/// can replace components without touching feature code (blueprint §15).
abstract final class NColors {
  static const canvas = Color(0xFFFCF9F5);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF6F3EF);
  static const surfaceContainer = Color(0xFFF0EDEA);
  static const tonalInset = Color(0xFFF4F1EA);
  static const hairline = Color(0xFFEFECE6);
  static const onSurface = Color(0xFF1C1C1A);
  static const onSurfaceVariant = Color(0xFF404943);
  static const outline = Color(0xFF707973);
  static const outlineVariant = Color(0xFFBFC9C1);
  static const primary = Color(0xFF0F5238);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF2D6A4F);
  static const onPrimaryContainer = Color(0xFFA8E7C5);
  static const secondary = Color(0xFF4C6358);
  static const secondaryContainer = Color(0xFFCEE9DA);
  static const onSecondaryContainer = Color(0xFF52695E);
  static const tertiary = Color(0xFF634019);
  static const tertiaryContainer = Color(0xFF7E572E);
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
  static const mockBanner = Color(0xFF623F18);
}

abstract final class NSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 40.0;
  static const pageMargin = 20.0;
}

abstract final class NRadius {
  static const sm = 4.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const card = 22.0;
  static const pill = 9999.0;
}

/// Minimum interactive size (blueprint §15: 44–48 logical px).
const double kMinTapTarget = 48;

/// Type scale from the export. Plus Jakarta Sans is not bundled yet (asset licensing/packaging is
/// part of design integration); the platform font is used with the same sizes and weights.
abstract final class NType {
  static const displaySm = TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 36 / 28, letterSpacing: -0.56);
  static const headlineLg = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 32 / 24, letterSpacing: -0.36);
  static const headlineMd = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 28 / 20, letterSpacing: -0.2);
  static const headlineSm = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 24 / 18);
  static const bodyLg = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 26 / 16);
  static const bodyMd = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 22 / 14);
  static const bodySm = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, height: 18 / 13);
  static const labelLg = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 20 / 14, letterSpacing: 0.14);
  static const labelMd = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 16 / 12, letterSpacing: 0.24);
}
