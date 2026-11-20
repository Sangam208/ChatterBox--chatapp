import 'dart:convert';

import 'package:chatterbox/models/message_model.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:chatterbox/models/error_model.dart';

final chatServicesProvider = Provider((ref) => ChatServices(client: Client()));

final messagesListProvider = StateProvider<List<MessageModel>>((ref) => []);

class ChatServices {
  final Client _client;
  ChatServices({required client}) : _client = client;

  // save message to DB
  Future<ErrorModel> saveMessage({
    required String? token,
    required WidgetRef ref,
    required String senderId,
    required String receiverId,
    required message,
  }) async {
    ErrorModel error = ErrorModel(error: 'Failed to send message', data: null);
    try {
      if (token != null) {
        final newMessage = MessageModel(
          senderId: senderId,
          receiverId: receiverId,
          message: message,
        );
        var response = await _client.post(
          Uri.parse('$host/messages'),
          headers: {"Content-Type": "application/json", "x-auth-token": token},
          body: jsonEncode(newMessage.toMap()),
        );

        switch (response.statusCode) {
          case 200:
            error = ErrorModel(error: null, data: newMessage);
            break;
          default:
            error = ErrorModel(
              error:
                  'Statuscode: ${response.statusCode}\nUnable to save message',
              data: null,
            );
        }
      } else {
        error = ErrorModel(error: 'Token not found', data: null);
      }
    } catch (e) {
      debugPrint(e.toString());
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  // fetch filtered messages from DB
  Future<ErrorModel> getMessages(
    String? token,
    String senderId,
    String receiverId,
  ) async {
    ErrorModel error = ErrorModel(
      error: 'Failed to fetch messages',
      data: null,
    );
    try {
      if (token != null) {
        var response = await _client.get(
          Uri.parse('$host/c/$senderId/$receiverId'),
          headers: {"Content-Type": "application/json", "x-auth-token": token},
        );

        switch (response.statusCode) {
          case 200:
            final body = jsonDecode(response.body);
            List<MessageModel> messages =
                (body['messages'] as List)
                    .map((msg) => MessageModel.fromJson(jsonEncode(msg)))
                    .toList();
            error = ErrorModel(error: null, data: messages);
            break;
          default:
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
}
