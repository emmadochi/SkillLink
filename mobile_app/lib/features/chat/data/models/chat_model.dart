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
  @JsonKey(name: 'message_type', defaultValue: 'text')
  final String messageType;
  @JsonKey(name: 'media_url')
  final String? mediaUrl;
  @JsonKey(name: 'media_duration')
  final int? mediaDuration;
  @JsonKey(name: 'is_read', defaultValue: 0)
  final int isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.messageType = 'text',
    this.mediaUrl,
    this.mediaDuration,
    this.isRead = 0,
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
  @JsonKey(name: 'last_message_type', defaultValue: 'text')
  final String? lastMessageType;
  @JsonKey(name: 'last_time')
  final String? lastTime;

  ChatConversation({
    required this.partnerId,
    required this.partnerName,
    this.partnerAvatar,
    this.lastMessage,
    this.lastMessageType = 'text',
    this.lastTime,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) => _$ChatConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ChatConversationToJson(this);
}
