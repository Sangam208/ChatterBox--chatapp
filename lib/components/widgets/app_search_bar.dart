import 'package:chatterbox/views/user_search_screen.dart';
import 'package:material_ui/material_ui.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    return SearchBar(
      readOnly: true,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const UserSearchScreen())),
      leading: Icon(Icons.search_rounded, color: colors.primary),
      hintText: 'Search people',
      elevation: const WidgetStatePropertyAll(0),
      constraints: const BoxConstraints(minHeight: 54),
      backgroundColor: WidgetStatePropertyAll(colors.tertiary),
      shape: WidgetStatePropertyAll(shape),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16),
      ),
      hintStyle: WidgetStatePropertyAll(
        Theme.of(context).textTheme.bodyLarge
            ?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}
