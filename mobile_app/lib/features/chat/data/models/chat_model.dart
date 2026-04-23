import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatMessage {
  final int id;
  @JsonKey(name: 'sender_id')
  final int senderId;
  @JsonKey(name: 'receiver_id')
  final int receiverId;
  final String message;
  @JsonKey(name: 'is_read')
  final int isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

@JsonSerializable()
class ChatConversation {
  @JsonKey(name: 'partner_id')
  final int partnerId;
  @JsonKey(name: 'partner_name')
  final String partnerName;
  @JsonKey(name: 'partner_avatar')
  final String? partnerAvatar;
  @JsonKey(name: 'last_message')
  final String? lastMessage;
  @JsonKey(name: 'last_time')
  final String? lastTime;

  ChatConversation({
    required this.partnerId,
    required this.partnerName,
    this.partnerAvatar,
    this.lastMessage,
    this.lastTime,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) => _$ChatConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ChatConversationToJson(this);
}
