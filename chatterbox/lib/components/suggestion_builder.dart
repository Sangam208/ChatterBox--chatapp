import 'package:chatterbox/models/user_model.dart';
import 'package:flutter/material.dart';

typedef OnUserTap = void Function(UserModel user);

List<Widget> buildUserSuggestions({
  required List<UserModel> users,
  required String? query,
  required OnUserTap onTap,
}) {
  if (query == null || query.isEmpty) return [];

  final filtered = users.where(
    (user) => user.name.toLowerCase().startsWith(query.toLowerCase()),
  );

  return List<Widget>.generate(filtered.length, (index) {
    final user = filtered.elementAt(index);
    return ListTile(
      onTap: () => onTap(user),
      leading: CircleAvatar(
        radius: 15,
        backgroundImage: AssetImage('assets/images/default_avatar.png'),
      ),
      title: Text(user.name),
    );
  });
}
