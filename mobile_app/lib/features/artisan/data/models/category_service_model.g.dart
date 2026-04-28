// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryService _$CategoryServiceFromJson(Map<String, dynamic> json) =>
    CategoryService(
      id: (json['id'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      name: json['service_name'] as String,
      iconName: json['icon_name'] as String?,
    );

Map<String, dynamic> _$CategoryServiceToJson(CategoryService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category_id': instance.categoryId,
      'service_name': instance.name,
      'icon_name': instance.iconName,
    };
