// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artisan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Artisan _$ArtisanFromJson(Map<String, dynamic> json) => Artisan(
      userId: (json['user_id'] as num).toInt(),
      bio: json['bio'] as String?,
      experienceYears: (json['experience_years'] as num?)?.toInt() ?? 0,
      rating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      locationName: json['location_name'] as String?,
      skill: json['skill'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ArtisanToJson(Artisan instance) => <String, dynamic>{
      'user_id': instance.userId,
      'bio': instance.bio,
      'experience_years': instance.experienceYears,
      'average_rating': instance.rating,
      'location_name': instance.locationName,
      'skill': instance.skill,
      'user': instance.user,
    };
