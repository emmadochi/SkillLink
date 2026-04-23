// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artisan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Artisan _$ArtisanFromJson(Map<String, dynamic> json) => Artisan(
      userId: Artisan._toInt(json['user_id']),
      bio: json['bio'] as String?,
      experienceYears: json['experience_years'] == null
          ? 0
          : Artisan._toInt(json['experience_years']),
      categoryId: Artisan._toInt(json['category_id']),
      rating: json['average_rating'] == null
          ? 0.0
          : Artisan._toDouble(json['average_rating']),
      locationName: json['location_name'] as String?,
      businessAddress: json['business_address'] as String?,
      guarantorName: json['guarantor_name'] as String?,
      guarantorPhone: json['guarantor_phone'] as String?,
      identityVerified: json['identity_verified'] == null
          ? false
          : Artisan._toBool(json['identity_verified']),
      identityStatus: json['identity_status'] as String?,
      isAvailable: json['is_available'] == null
          ? true
          : Artisan._toBool(json['is_available']),
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
      'category_id': instance.categoryId,
      'average_rating': instance.rating,
      'location_name': instance.locationName,
      'business_address': instance.businessAddress,
      'guarantor_name': instance.guarantorName,
      'guarantor_phone': instance.guarantorPhone,
      'identity_verified': instance.identityVerified,
      'identity_status': instance.identityStatus,
      'is_available': instance.isAvailable,
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
