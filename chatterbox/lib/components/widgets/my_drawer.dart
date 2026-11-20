import 'package:chatterbox/colors.dart';
import 'package:chatterbox/preferences/theme_preference.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:chatterbox/themes/light_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  void logout(WidgetRef ref) {
    ref.read(authRepositoryProvider).logOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Drawer(
      backgroundColor: !theme ? darkMode.colorScheme.primary : kGreyColorDark,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: kGreyColorLight),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/default_avatar.png'),
            ),
          ),
          ListTile(
            title: Center(
              child: Text(
                '${theme ? 'D A R K' : 'L I G H T'}  M O D E',
                style: TextStyle(
                  color: kWhiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            trailing: Switch(
              inactiveThumbColor: kWhiteColor,
              trackColor: WidgetStateProperty.all(kGreyColor),
              value: theme,
              onChanged: (_) => toggleTheme(ref),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: kWhiteColor),
            title: const Text(
              'L O G  O U T',
              style: TextStyle(color: kWhiteColor),
            ),
            onTap: () => logout(ref),
          ),
        ],
      ),
    );
  }
}
