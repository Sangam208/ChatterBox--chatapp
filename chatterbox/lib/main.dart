import 'package:chatterbox/auth/auth_gate.dart';
import 'package:chatterbox/preferences/theme_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  final savedTheme = await loadTheme();
  runApp(
    ProviderScope(
      overrides: [themeProvider.overrideWith((ref) => savedTheme)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthGate();
  }
}
