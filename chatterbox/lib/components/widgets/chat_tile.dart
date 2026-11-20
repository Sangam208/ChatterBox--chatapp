import 'package:chatterbox/models/error_model.dart';
import 'package:chatterbox/models/user_model.dart';
import 'package:chatterbox/providers/selected_user_provider.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ChatTile extends ConsumerStatefulWidget {
  final UserModel receiverUser;
  const ChatTile({super.key, required this.receiverUser});

  @override
  ConsumerState<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends ConsumerState<ChatTile> {
  ErrorModel? errorModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/images/default_avatar.png'),
      ),
      title: Text(
        widget.receiverUser.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      // subtitle: Text(
      //   ref.watch(latestMessageProvider)?.message ?? '',
      //   style: TextStyle(
      //     fontWeight: FontWeight.normal,
      //     fontSize: 16,
      //     color: Theme.of(context).colorScheme.primary,
      //   ),
      //   overflow: TextOverflow.ellipsis,
      // ),
      onTap: () {
        ref
            .read(selectedUserProvider.notifier)
            .update((state) => widget.receiverUser);
        Routemaster.of(
          context,
        ).push('/c/${ref.watch(userProvider)!.uid}/${widget.receiverUser.uid}');
      },
    );
  }
}
