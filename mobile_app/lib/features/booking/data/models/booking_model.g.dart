// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
      id: (json['id'] as num).toInt(),
      bookingNumber: json['booking_number'] as String,
      customerId: (json['customer_id'] as num).toInt(),
      artisanId: (json['artisan_id'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      serviceDescription: json['service_description'] as String?,
      scheduledAt: json['scheduled_at'] as String,
      status: json['status'] as String,
      price: Booking._toDouble(json['price']),
      platformFee: Booking._toDouble(json['platform_fee']),
      artisanPayout: Booking._toDouble(json['artisan_payout']),
      createdAt: json['created_at'] as String?,
      partnerName: json['partner_name'] as String?,
      partnerAvatar: json['partner_avatar'] as String?,
      categoryName: json['category_name'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
    );

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
      'id': instance.id,
      'booking_number': instance.bookingNumber,
      'customer_id': instance.customerId,
      'artisan_id': instance.artisanId,
      'category_id': instance.categoryId,
      'service_description': instance.serviceDescription,
      'scheduled_at': instance.scheduledAt,
      'status': instance.status,
      'price': instance.price,
      'platform_fee': instance.platformFee,
      'artisan_payout': instance.artisanPayout,
      'created_at': instance.createdAt,
      'partner_name': instance.partnerName,
      'partner_avatar': instance.partnerAvatar,
      'category_name': instance.categoryName,
      'cancellation_reason': instance.cancellationReason,
    };
