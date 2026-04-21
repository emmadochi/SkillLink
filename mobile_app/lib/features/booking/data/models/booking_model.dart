import 'package:json_annotation/json_annotation.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class Booking {
  final int id;
  @JsonKey(name: 'booking_number')
  final String bookingNumber;
  @JsonKey(name: 'customer_id')
  final int customerId;
  @JsonKey(name: 'artisan_id')
  final int artisanId;
  @JsonKey(name: 'category_id')
  final int categoryId;
  @JsonKey(name: 'service_description')
  final String? serviceDescription;
  @JsonKey(name: 'scheduled_at')
  final String scheduledAt;
  final String status;
  final double price;
  @JsonKey(name: 'platform_fee')
  final double platformFee;
  @JsonKey(name: 'artisan_payout')
  final double artisanPayout;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  // Joined fields from backend
  @JsonKey(name: 'partner_name')
  final String? partnerName;
  @JsonKey(name: 'partner_avatar')
  final String? partnerAvatar;
  @JsonKey(name: 'category_name')
  final String? categoryName;

  Booking({
    required this.id,
    required this.bookingNumber,
    required this.customerId,
    required this.artisanId,
    required this.categoryId,
    this.serviceDescription,
    required this.scheduledAt,
    required this.status,
    required this.price,
    required this.platformFee,
    required this.artisanPayout,
    this.createdAt,
    this.partnerName,
    this.partnerAvatar,
    this.categoryName,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

  Map<String, dynamic> toJson() => _$BookingToJson(this);
}
