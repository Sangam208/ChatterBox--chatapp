import 'package:chatterbox/colors.dart';
import 'package:chatterbox/preferences/theme_preference.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:chatterbox/views/home_screen.dart';
import 'package:chatterbox/views/login_screen.dart';
import 'package:chatterbox/themes/light_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      final result = await ref.read(authRepositoryProvider).getUserData();
      if (!mounted) return;
      if (result.data != null) {
        ref.read(userProvider.notifier).state = result.data;
      }
    } catch (error) {
      debugPrint('Unable to restore session: $error');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider) ? darkMode : lightMode;
    final user = ref.watch(userProvider);
    return MaterialApp(
      title: 'ChatterBox',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: isLoading
          ? Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: kBlackColor),
              ),
            )
          : user != null && user.token.isNotEmpty
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
