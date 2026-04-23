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
      businessAddress: json['business_address'] as String?,
      guarantorName: json['guarantor_name'] as String?,
      guarantorPhone: json['guarantor_phone'] as String?,
      identityVerified: json['identity_verified'] as bool? ?? false,
      identityStatus: json['identity_status'] as String?,
      skill: json['skill'] as String?,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      portfolio: (json['portfolio'] as List<dynamic>?)
          ?.map((e) => PortfolioItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ArtisanToJson(Artisan instance) => <String, dynamic>{
      'user_id': instance.userId,
      'bio': instance.bio,
      'experience_years': instance.experienceYears,
      'average_rating': instance.rating,
      'location_name': instance.locationName,
      'business_address': instance.businessAddress,
      'guarantor_name': instance.guarantorName,
      'guarantor_phone': instance.guarantorPhone,
      'identity_verified': instance.identityVerified,
      'identity_status': instance.identityStatus,
      'skill': instance.skill,
      'user': instance.user,
      'portfolio': instance.portfolio,
    };

PortfolioItem _$PortfolioItemFromJson(Map<String, dynamic> json) =>
    PortfolioItem(
      id: (json['id'] as num).toInt(),
      imageUrl: json['image_url'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PortfolioItemToJson(PortfolioItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image_url': instance.imageUrl,
      'description': instance.description,
    };
