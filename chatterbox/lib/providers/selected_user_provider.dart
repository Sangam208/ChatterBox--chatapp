import 'package:chatterbox/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedUserProvider = StateProvider<UserModel?>((ref) => null);
