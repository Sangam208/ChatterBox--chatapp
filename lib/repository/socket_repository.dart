import 'package:chatterbox/clients/socket_client.dart';

class SocketRepository {
  SocketRepository({required String token})
    : _client = SocketClient(token: token);

  final SocketClient _client;

  void disconnect() {
    _client.dispose();
  }

  void joinRoom(String senderId, String receiverId) {
    _client.socket.emit('join', {
      "senderId": senderId.toString(),
      "receiverId": receiverId.toString(),
    });
  }

  void sendMessage(String text, String senderId, String receiverId) {
    _client.socket.emit('message', {
      "senderId": senderId,
      "receiverId": receiverId,
      "message": text,
    });
  }

  void messageListener(Function(Map<String, dynamic>) func) {
    _client.socket.on('changes', (message) {
      if (message is Map) func(Map<String, dynamic>.from(message));
    });
  }

  void removeListener() {
    _client.socket.off('changes');
  }
}
