import 'package:chatterbox/colors.dart';
import 'package:material_ui/material_ui.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Colors.grey.shade500,
    secondary: Colors.grey.shade200,
    tertiary: Colors.grey.shade400,
    inversePrimary: Colors.grey.shade900,
  ),
  appBarTheme: AppBarTheme(
    centerTitle: false,
    backgroundColor: kTransparentColor,
    elevation: 6.0,
  ),
);

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade600,
    secondary: Colors.grey.shade700,
    tertiary: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade300,
  ),
  appBarTheme: AppBarTheme(
    centerTitle: false,
    backgroundColor: kTransparentColor,
    elevation: 6.0,
  ),
);
