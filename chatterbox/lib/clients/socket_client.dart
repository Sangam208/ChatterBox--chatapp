import 'package:chatterbox/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketClient {
  io.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    socket = io.io(host, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 2000,
    });
    socket!.connect();

    // debugging logs
    socket!.onConnect((_) => debugPrint('Connected to WebSocket'));
    socket!.onDisconnect((_) => debugPrint('Disconnected from WebSocket'));
    socket!.onError((e) => debugPrint('WebSocket Error: $e'));
    socket!.onReconnectAttempt((_) => debugPrint('Reconnecting...'));
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }
}
