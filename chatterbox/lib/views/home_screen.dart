import 'package:chatterbox/colors.dart';
import 'package:chatterbox/components/my_textstyle.dart';
import 'package:chatterbox/components/widgets/app_search_bar.dart';
import 'package:chatterbox/components/widgets/chat_tile.dart';
import 'package:chatterbox/components/widgets/my_drawer.dart';
import 'package:chatterbox/components/widgets/my_search_anchor.dart';
import 'package:chatterbox/models/error_model.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ErrorModel? errorModel;

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  void getAllUsers() async {
    errorModel = await ref
        .read(authRepositoryProvider)
        .getAllUsers(ref.read(userProvider)!.token);
    if (errorModel != null && errorModel!.data != null) {
      ref.read(usersListProvider.notifier).update((state) => errorModel!.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersListProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        automaticallyImplyLeading: true,
        title: const Text('chatterbox', style: TextStyle(fontSize: 24)),
        actionsPadding: const EdgeInsets.only(right: 10),
        actions: [MySearchAnchor()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
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
                      child: Text(
                        'Find new friends and start a conversation',
                        style: textStyle,
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
