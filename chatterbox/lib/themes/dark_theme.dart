import 'package:chatterbox/colors.dart';
import 'package:flutter/material.dart';

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
