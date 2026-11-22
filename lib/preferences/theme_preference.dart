import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateProvider<bool>((ref) => false);

Future<bool> loadTheme() async {
  final preferences = SharedPreferencesAsync();
  return (await preferences.getBool('isDarkMode')) ?? false;
}

Future<void> toggleTheme(WidgetRef ref) async {
  final preferences = SharedPreferencesAsync();
  final newTheme = !ref.read(themeProvider);
  ref.read(themeProvider.notifier).state = newTheme;
  await preferences.setBool('isDarkMode', newTheme);
}
