import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateProvider<bool>((ref) => false);

Future<bool> loadTheme() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool('isDarkMode') ?? false;
}

Future<void> toggleTheme(WidgetRef ref) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final newTheme = !ref.read(themeProvider);
  ref.read(themeProvider.notifier).state = newTheme;
  await preferences.setBool('isDarkMode', newTheme);
}
