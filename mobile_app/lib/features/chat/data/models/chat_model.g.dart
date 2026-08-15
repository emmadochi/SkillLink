// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: (json['id'] as num).toInt(),
      senderId: (json['sender_id'] as num).toInt(),
      receiverId: (json['receiver_id'] as num).toInt(),
      message: json['message'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      mediaUrl: json['media_url'] as String?,
      mediaDuration: (json['media_duration'] as num?)?.toInt(),
      isRead: (json['is_read'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender_id': instance.senderId,
      'receiver_id': instance.receiverId,
      'message': instance.message,
      'message_type': instance.messageType,
      'media_url': instance.mediaUrl,
      'media_duration': instance.mediaDuration,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
    };

ChatConversation _$ChatConversationFromJson(Map<String, dynamic> json) =>
    ChatConversation(
      partnerId: (json['partner_id'] as num).toInt(),
      partnerName: json['partner_name'] as String,
      partnerAvatar: json['partner_avatar'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageType: json['last_message_type'] as String? ?? 'text',
      lastTime: json['last_time'] as String?,
    );

Map<String, dynamic> _$ChatConversationToJson(ChatConversation instance) =>
    <String, dynamic>{
      'partner_id': instance.partnerId,
      'partner_name': instance.partnerName,
      'partner_avatar': instance.partnerAvatar,
      'last_message': instance.lastMessage,
      'last_message_type': instance.lastMessageType,
      'last_time': instance.lastTime,
    };
