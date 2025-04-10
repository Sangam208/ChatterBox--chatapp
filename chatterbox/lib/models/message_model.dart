// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MessageModel {
  final String message;
  final String senderId;
  final String receiverId;

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      message: map['message'] as String? ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MessageModel(senderId: $senderId, receiverId: $receiverId, message: $message)';
  }

  MessageModel copyWith({
    String? messageId,
    String? message,
    String? senderId,
    String? receiverId,
  }) {
    return MessageModel(
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
    );
  }
}
