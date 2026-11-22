import 'package:chatterbox/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the server user document used by the session flow', () {
    final user = UserModel.fromJson(
      '{"_id":"user-1","name":"Alex","email":"alex@example.com",'
      '"profilePic":"","token":"session-token"}',
    );

    expect(user.uid, 'user-1');
    expect(user.name, 'Alex');
    expect(user.email, 'alex@example.com');
    expect(user.profilePic, isEmpty);
    expect(user.token, 'session-token');
  });
}
