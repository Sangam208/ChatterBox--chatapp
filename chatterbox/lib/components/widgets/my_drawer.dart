import 'package:chatterbox/preferences/theme_preference.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  Future<void> logout(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authRepositoryProvider).logOut();
    } catch (error) {
      debugPrint('Sign-out error: $error');
    } finally {
      if (context.mounted) ref.read(userProvider.notifier).state = null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final user = ref.watch(userProvider);
    final colors = Theme.of(context).colorScheme;
    return Drawer(
      backgroundColor: colors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colors.tertiary),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: colors.primaryContainer,
                  child: ClipOval(
                    child: user?.profilePic.isNotEmpty == true
                        ? Image.network(
                            user!.profilePic,
                            width: 68,
                            height: 68,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.person,
                              size: 38,
                              color: colors.onPrimaryContainer,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 38,
                            color: colors.onPrimaryContainer,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'ChatterBox',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              theme ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: colors.onSurfaceVariant,
            ),
            title: const Text('Dark mode'),
            trailing: Switch.adaptive(
              value: theme,
              onChanged: (_) => toggleTheme(ref),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: colors.error),
            title: const Text('Log out'),
            onTap: () async => logout(context, ref),
          ),
        ],
      ),
    );
  }
}
