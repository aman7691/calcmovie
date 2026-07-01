import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Application theme - dark movie-browsing themed UI
class AppTheme {
  AppTheme._();

  // Color palette
  static const Color primary = Color(0xFFE50914);       // Netflix-style red
  static const Color primaryDark = Color(0xFFB20710);
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2A2A2A);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Color(0xFFE0E0E0);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onSurfaceVariant = Color(0xFFB0B0B0);
  static const Color starColor = Color(0xFFFFC107);
  static const Color divider = Color(0xFF2E2E2E);

  // Calculator colors
  static const Color calcBackground = Color(0xFF1C1C1E);
  static const Color calcDisplay = Color(0xFF2C2C2E);
  static const Color calcButtonDark = Color(0xFF3A3A3C);
  static const Color calcButtonMid = Color(0xFF505050);
  static const Color calcButtonAction = Color(0xFFFF9F0A); // iOS-style orange
  static const Color calcButtonEqual = Color(0xFFE50914);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
      ),
      scaffoldBackgroundColor: background,
      cardColor: cardColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        // Prevent Material 3 from tinting the AppBar when content scrolls under it
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        // Force light status-bar icons (white) on our dark background.
        // This also ensures the status bar area is NOT drawn over the AppBar.
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.dark,       // iOS: light icons
          statusBarIconBrightness: Brightness.light,  // Android: light icons
          systemNavigationBarColor: surface,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: onSurfaceVariant),
        prefixIconColor: onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: onBackground, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: onBackground, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: onBackground, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: onBackground, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: onBackground, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: onSurfaceVariant, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: onBackground),
        bodyMedium: TextStyle(color: onSurfaceVariant),
        bodySmall: TextStyle(color: onSurfaceVariant, fontSize: 12),
        labelLarge: TextStyle(color: onBackground, fontWeight: FontWeight.w600),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary,
        labelStyle: const TextStyle(color: onBackground, fontSize: 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      iconTheme: const IconThemeData(color: onBackground),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: const TextStyle(color: onBackground),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
