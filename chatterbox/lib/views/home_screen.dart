import 'package:chatterbox/colors.dart';
import 'package:chatterbox/components/widgets/app_search_bar.dart';
import 'package:chatterbox/components/widgets/chat_tile.dart';
import 'package:chatterbox/components/widgets/my_drawer.dart';
import 'package:chatterbox/components/widgets/my_search_anchor.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isLoadingUsers = true;
  String? _usersError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      getAllUsers();
    });
  }

  Future<void> getAllUsers() async {
    if (!mounted) return;
    setState(() {
      _isLoadingUsers = true;
      _usersError = null;
    });
    final result = await ref
        .read(authRepositoryProvider)
        .getAllUsers(ref.read(userProvider)!.token);
    if (!mounted) return;
    if (result.data != null) {
      ref.read(usersListProvider.notifier).state = result.data;
      setState(() => _isLoadingUsers = false);
    } else {
      setState(() {
        _isLoadingUsers = false;
        _usersError = result.error ?? 'Could not load people. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersListProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: true,
        title: const Text('chatterbox', style: TextStyle(fontSize: 24)),
        actionsPadding: const EdgeInsets.only(right: 10),
        actions: [MySearchAnchor()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                elevation: 0.0,
                backgroundColor: kTransparentColor,
                automaticallyImplyLeading: false,
                title: AppSearchBar(),
              ),

              users.isNotEmpty
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return ChatTile(receiverUser: users[index]);
                      }, childCount: users.length),
                    )
                  : SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isLoadingUsers) ...[
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Loading your conversations…',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ] else if (_usersError != null) ...[
                                  Icon(
                                    Icons.cloud_off_outlined,
                                    size: 36,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _usersError!,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  FilledButton.tonalIcon(
                                    onPressed: getAllUsers,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Try again'),
                                  ),
                                ] else ...[
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Icon(
                                        Icons.forum_outlined,
                                        size: 32,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Find new friends and start a conversation',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                          height: 1.45,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Search for someone by name to get started.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      drawer: const MyDrawer(),
    );
  }
}
