import 'package:chatterbox/models/user_model.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedUserProvider = StateProvider<UserModel?>((ref) => null);
