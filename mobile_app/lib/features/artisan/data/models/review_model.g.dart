// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
      id: (json['id'] as num).toInt(),
      bookingId: (json['booking_id'] as num).toInt(),
      customerId: (json['customer_id'] as num).toInt(),
      artisanId: (json['artisan_id'] as num).toInt(),
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String?,
      customerName: json['customer_name'] as String?,
      customerAvatar: json['customer_avatar'] as String?,
    );

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'customer_id': instance.customerId,
      'artisan_id': instance.artisanId,
      'rating': instance.rating,
      'comment': instance.comment,
      'created_at': instance.createdAt,
      'customer_name': instance.customerName,
      'customer_avatar': instance.customerAvatar,
    };
