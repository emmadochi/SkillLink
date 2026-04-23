// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] == null
          ? false
          : User._boolFromInt(json['is_verified']),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'phone': instance.phone,
      'avatar_url': instance.avatarUrl,
      'is_verified': User._boolToInt(instance.isVerified),
    };
