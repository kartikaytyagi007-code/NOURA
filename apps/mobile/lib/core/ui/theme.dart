import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildLightTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: NColors.primary,
    onPrimary: NColors.onPrimary,
    primaryContainer: NColors.primaryContainer,
    onPrimaryContainer: NColors.onPrimaryContainer,
    secondary: NColors.secondary,
    onSecondary: NColors.onPrimary,
    secondaryContainer: NColors.secondaryContainer,
    onSecondaryContainer: NColors.onSecondaryContainer,
    tertiary: NColors.tertiary,
    onTertiary: NColors.onPrimary,
    tertiaryContainer: NColors.tertiaryContainer,
    error: NColors.error,
    onError: NColors.onError,
    errorContainer: NColors.errorContainer,
    onErrorContainer: NColors.onErrorContainer,
    surface: NColors.canvas,
    onSurface: NColors.onSurface,
    onSurfaceVariant: NColors.onSurfaceVariant,
    surfaceContainerLowest: NColors.surface,
    surfaceContainerLow: NColors.surfaceContainerLow,
    surfaceContainer: NColors.surfaceContainer,
    outline: NColors.outline,
    outlineVariant: NColors.outlineVariant,
  );

  const pill = StadiumBorder();
  const buttonPadding = EdgeInsets.symmetric(horizontal: 28, vertical: 14);
  const minSize = Size(kMinTapTarget, kMinTapTarget);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: NColors.canvas,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    textTheme: const TextTheme(
      displaySmall: NType.displaySm,
      headlineLarge: NType.headlineLg,
      headlineMedium: NType.headlineMd,
      headlineSmall: NType.headlineSm,
      titleMedium: NType.headlineSm,
      bodyLarge: NType.bodyLg,
      bodyMedium: NType.bodyMd,
      bodySmall: NType.bodySm,
      labelLarge: NType.labelLg,
      labelMedium: NType.labelMd,
    ).apply(bodyColor: NColors.onSurface, displayColor: NColors.onSurface),
    appBarTheme: AppBarTheme(
      backgroundColor: NColors.canvas,
      foregroundColor: NColors.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      // A custom title style replaces the foreground colour, so it must carry its own.
      titleTextStyle: NType.headlineMd.copyWith(color: NColors.onSurface),
    ),
    cardTheme: CardThemeData(
      color: NColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NRadius.card),
        side: const BorderSide(color: NColors.hairline),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: pill,
        padding: buttonPadding,
        minimumSize: minSize,
        textStyle: NType.labelLg,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: pill,
        padding: buttonPadding,
        minimumSize: minSize,
        textStyle: NType.labelLg,
        foregroundColor: NColors.onSurface,
        backgroundColor: NColors.tonalInset,
        side: const BorderSide(color: NColors.hairline),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: minSize, textStyle: NType.labelLg),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: NSpace.md, vertical: NSpace.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NRadius.lg),
        borderSide: const BorderSide(color: NColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NRadius.lg),
        borderSide: const BorderSide(color: NColors.outlineVariant),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: NColors.surface,
      indicatorColor: NColors.secondaryContainer,
      height: 72,
    ),
  );
}
