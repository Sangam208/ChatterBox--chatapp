import 'package:chatterbox/repository/auth_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  SocketClient({required String token})
    : socket = io.io(host, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 2000,
        'auth': {'token': token},
      }) {
    socket.onConnect((_) => debugPrint('Connected to Socket.IO'));
    socket.onDisconnect((_) => debugPrint('Disconnected from Socket.IO'));
    socket.onError((error) => debugPrint('Socket.IO error: $error'));
    socket.onReconnectAttempt((_) => debugPrint('Reconnecting to Socket.IO'));
    socket.connect();
  }

  final io.Socket socket;

  void dispose() {
    socket.dispose();
  }
}
