import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chatterbox/views/user_search_screen.dart';
import 'package:material_ui/material_ui.dart';

class MySearchAnchor extends StatelessWidget {
  const MySearchAnchor({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const UserSearchScreen())),
      icon: FaIcon(FontAwesomeIcons.penToSquare, color: colors.primary),
    );
  }
}
