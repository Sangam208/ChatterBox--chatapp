import 'package:material_ui/material_ui.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    surface: const Color(0xFFF8F9FC),
    primary: const Color(0xFF49658F),
    secondary: const Color(0xFF66758B),
    tertiary: const Color(0xFFE9EEF6),
    inversePrimary: const Color(0xFF314B70),
  ),
  appBarTheme: AppBarTheme(
    centerTitle: false,
    backgroundColor: const Color(0xFFF8F9FC),
    foregroundColor: const Color(0xFF20242B),
    elevation: 0,
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    surface: const Color(0xFF11151B),
    primary: const Color(0xFFB3C9EC),
    secondary: const Color(0xFFC0C8D5),
    tertiary: const Color(0xFF252C36),
    inversePrimary: const Color(0xFFD6E3FA),
  ),
  appBarTheme: AppBarTheme(
    centerTitle: false,
    backgroundColor: const Color(0xFF11151B),
    foregroundColor: const Color(0xFFE6EAF0),
    elevation: 0,
  ),
);
