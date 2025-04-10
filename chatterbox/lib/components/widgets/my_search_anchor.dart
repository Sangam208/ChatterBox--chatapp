import 'package:chatterbox/components/suggestion_builder.dart';
import 'package:chatterbox/providers/selected_user_provider.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class MySearchAnchor extends ConsumerStatefulWidget {
  const MySearchAnchor({super.key});

  @override
  ConsumerState<MySearchAnchor> createState() => _MySearchAnchorState();
}

class _MySearchAnchorState extends ConsumerState<MySearchAnchor> {
  final SearchController _searchController = SearchController();
  String? _searchQuery;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    return SearchAnchor(
      searchController: _searchController,
      builder: (context, controller) {
        return IconButton(
          onPressed: () {
            _searchController.openView();
          },
          icon: FaIcon(FontAwesomeIcons.penToSquare),
        );
      },
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
