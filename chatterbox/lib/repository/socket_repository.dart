import 'package:chatterbox/clients/socket_client.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketRepository {
  final _socketClient = SocketClient.instance.socket!;

  Socket get socketClient => _socketClient;

  void connect() {
    if (!_socketClient.connected) {
      _socketClient.connect();
    }
  }

  void disconnect() {
    _socketClient.disconnect();
  }

  void joinRoom(String senderId, String receiverId) {
    connect(); // Ensure connection before joining
    _socketClient.emit('join', {
      "senderId": senderId.toString(),
      "receiverId": receiverId.toString(),
    });
  }

  void sendMessage(String text, String senderId, String receiverId) {
    connect(); // Ensure connection before sending message
    _socketClient.emit('message', {
      "senderId": senderId,
      "receiverId": receiverId,
      "message": text,
    });
  }

  void userJoinedListener(Function(Map<String, dynamic>) func) {
    _socketClient.on('user_joined', (message) => func(message));
  }

  void messageListener(Function(Map<String, dynamic>) func) {
    _socketClient.on('changes', (message) => func(message));
  }

  void removeListener() {
    _socketClient.off('changes');
    _socketClient.off('user_joined');
  }
}
