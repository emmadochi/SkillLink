// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      relatedId: (json['related_id'] as num?)?.toInt(),
      isRead: json['is_read'] == null
          ? false
          : NotificationModel._boolFromInt(json['is_read']),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'related_id': instance.relatedId,
      'is_read': NotificationModel._boolToInt(instance.isRead),
      'created_at': instance.createdAt,
    };
