import 'package:chatterbox/components/suggestion_builder.dart';
import 'package:chatterbox/providers/selected_user_provider.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class AppSearchBar extends ConsumerStatefulWidget {
  const AppSearchBar({super.key});

  @override
  ConsumerState<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends ConsumerState<AppSearchBar> {
  final SearchController _searchController = SearchController();
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: _searchController,
      barElevation: WidgetStatePropertyAll(1.0),
      barHintText: 'Search',
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.7,
        minHeight: 50,
      ),
      barBackgroundColor: WidgetStatePropertyAll(
        Theme.of(context).colorScheme.tertiary,
      ),
      suggestionsBuilder: (context, controller) {
        final users = ref.watch(usersListProvider);
        return buildUserSuggestions(
          users: users,
          query: _searchQuery,
          onTap: (user) {
            final currentUser = ref.read(userProvider);
            ref.read(selectedUserProvider.notifier).update((state) => user);
            Routemaster.of(context).push('/c/${currentUser!.uid}/${user.uid}');
            _searchController.closeView(user.name);
          },
        );
      },
    );
  }
}
