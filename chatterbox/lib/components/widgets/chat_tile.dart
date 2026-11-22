import 'package:chatterbox/models/user_model.dart';
import 'package:chatterbox/providers/selected_user_provider.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chatterbox/views/chat_screen.dart';

class ChatTile extends ConsumerWidget {
  final UserModel receiverUser;
  const ChatTile({super.key, required this.receiverUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        backgroundImage: AssetImage('assets/images/default_avatar.png'),
      ),
      title: Text(
        receiverUser.name,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 20,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      onTap: () {
        ref.read(selectedUserProvider.notifier).update((state) => receiverUser);
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ChatScreen(
              senderID: ref.read(userProvider)!.uid,
              receiverID: receiverUser.uid,
            ),
          ),
        );
      },
    );
  }
}
