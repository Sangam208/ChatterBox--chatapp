import 'dart:convert';

import 'package:chatterbox/models/message_model.dart';
import 'package:chatterbox/repository/auth_repository.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart';
import 'package:chatterbox/models/error_model.dart';
import 'package:chatterbox/utils/user_facing_error.dart';

final chatServicesProvider = Provider((ref) {
  final client = Client();
  ref.onDispose(client.close);
  return ChatServices(client: client);
});

final messagesListProvider = StateProvider<List<MessageModel>>((ref) => []);

class ChatServices {
  final Client _client;
  ChatServices({required this._client});

  // save message to DB
  Future<ErrorModel> saveMessage({
    required String? token,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    ErrorModel error = ErrorModel(
      error: 'Message could not be sent. Please try again.',
      data: null,
    );
    try {
      if (token != null) {
        final newMessage = MessageModel(
          senderId: senderId,
          receiverId: receiverId,
          message: message,
        );
        final response = await _client.post(
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
              error: userFacingHttpError(
                response.statusCode,
                fallback: 'Message could not be sent. Please try again.',
                notFoundMessage: 'This conversation could not be found.',
              ),
              data: null,
            );
        }
      } else {
        error = ErrorModel(
          error: 'Your session expired. Please sign in again.',
          data: null,
        );
      }
    } catch (e) {
      debugPrint('Unable to send message: $e');
      error = ErrorModel(
        error: userFacingException(
          e,
          fallback: 'Message could not be sent. Please try again.',
        ),
        data: null,
      );
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
        final response = await _client.get(
          Uri.parse('$host/c/$senderId/$receiverId'),
          headers: {"Content-Type": "application/json", "x-auth-token": token},
        );

        switch (response.statusCode) {
          case 200:
            final body = jsonDecode(response.body);
            List<MessageModel> messages = (body['messages'] as List)
                .map((msg) => MessageModel.fromJson(jsonEncode(msg)))
                .toList();
            error = ErrorModel(error: null, data: messages);
            break;
          default:
            error = ErrorModel(
              error: userFacingHttpError(
                response.statusCode,
                fallback: 'Could not load messages. Please try again.',
                notFoundMessage: 'This conversation could not be found.',
              ),
              data: null,
            );
        }
      } else {
        error = ErrorModel(
          error: 'Your session expired. Please sign in again.',
          data: null,
        );
      }
    } catch (e) {
      debugPrint('Unable to fetch messages: $e');
      error = ErrorModel(
        error: userFacingException(
          e,
          fallback: 'Could not load messages. Please try again.',
        ),
        data: null,
      );
    }
    return error;
  }
}
