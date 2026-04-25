// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      icon: json['icon'] as String?,
      isTechnical: json['is_technical'] == null
          ? false
          : Category._boolFromInt(json['is_technical']),
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'is_technical': Category._boolToInt(instance.isTechnical),
    };
