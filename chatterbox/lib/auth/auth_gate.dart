import 'package:chatterbox/colors.dart';
import 'package:chatterbox/models/error_model.dart';
import 'package:chatterbox/preferences/theme_preference.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:chatterbox/router.dart';
import 'package:chatterbox/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  ErrorModel? errorModel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    errorModel = await ref.read(authRepositoryProvider).getUserData();
    if (errorModel != null && errorModel!.data != null) {
      ref.read(userProvider.notifier).update((state) => errorModel!.data);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider) ? darkMode : lightMode;
    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Center(child: CircularProgressIndicator(color: kBlackColor)),
        ),
      );
    }
    return MaterialApp.router(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      title: 'ChatterBox',
      debugShowCheckedModeBanner: false,
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (context) {
          final user = ref.watch(userProvider);
          if (user != null && user.token.isNotEmpty) {
            return loggedInRoute;
          } else {
            return loggedOutRoute;
          }
        },
      ),
      routeInformationParser: const RoutemasterParser(),
      theme: theme,
    );
  }
}
