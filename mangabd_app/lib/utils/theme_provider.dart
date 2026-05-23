import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;

  ThemeData get theme => _isDark ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D1F12),
    fontFamily: 'Nunito',
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF00C853),
      secondary: const Color(0xFFFFD60A),
      tertiary: const Color(0xFF00E676),
      surface: const Color(0xFF132718),
      onPrimary: Colors.white,
      onSecondary: const Color(0xFF1a1a1a),
      onSurface: const Color(0xFFE8F5E9),
      error: const Color(0xFFFF4757),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF132718),
      elevation: 0,
      centerTitle: false,
      foregroundColor: Color(0xFFE8F5E9),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF132718),
      indicatorColor: const Color(0xFF00C853).withValues(alpha: 0.2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF00C853));
        }
        return const IconThemeData(color: Color(0xFF4A7A55));
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: Color(0xFF00C853),
            fontWeight: FontWeight.w700,
            fontSize: 11,
          );
        }
        return const TextStyle(
          color: Color(0xFF4A7A55),
          fontWeight: FontWeight.w500,
          fontSize: 11,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF132718),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A3320),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF4A7A55)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),
    useMaterial3: true,
  );

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF0FFF4),
    fontFamily: 'Nunito',
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF00C853),
      secondary: const Color(0xFFFFD60A),
      tertiary: const Color(0xFF00A844),
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: const Color(0xFF1a1a1a),
      onSurface: const Color(0xFF0D1F12),
      error: const Color(0xFFFF4757),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Color(0xFF0D1F12),
      shadowColor: Color(0x0F000000),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFF00C853).withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF00C853));
        }
        return const IconThemeData(color: Color(0xFF9CA3AF));
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: Color(0xFF00C853),
            fontWeight: FontWeight.w700,
            fontSize: 11,
          );
        }
        return const TextStyle(
          color: Color(0xFF9CA3AF),
          fontWeight: FontWeight.w500,
          fontSize: 11,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFE8F5E9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF00C853), width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),
    ),
    useMaterial3: true,
  );
}