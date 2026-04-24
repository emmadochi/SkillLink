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
  @JsonKey(fromJson: _toDouble)
  final double price;
  @JsonKey(name: 'platform_fee', fromJson: _toDouble)
  final double platformFee;
  @JsonKey(name: 'artisan_payout', fromJson: _toDouble)
  final double artisanPayout;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'offer_price', fromJson: _toDouble)
  final double? offerPrice;
  @JsonKey(name: 'counter_price', fromJson: _toDouble)
  final double? counterPrice;
  @JsonKey(name: 'negotiation_status')
  final String? negotiationStatus;
  @JsonKey(name: 'is_negotiated', fromJson: _toBool)
  final bool isNegotiated;

  static bool _toBool(dynamic val) => val == 1 || val == true || val == '1';

  static double _toDouble(dynamic val) => val is String ? (double.tryParse(val) ?? 0.0) : (val is int ? val.toDouble() : (val as double? ?? 0.0));
  static int _toInt(dynamic val) => val is String ? (int.tryParse(val) ?? 0) : (val as int? ?? 0);

  // Joined fields from backend
  @JsonKey(name: 'partner_name')
  final String? partnerName;
  @JsonKey(name: 'partner_avatar')
  final String? partnerAvatar;
  @JsonKey(name: 'category_name')
  final String? categoryName;
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;

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
    this.cancellationReason,
    this.offerPrice,
    this.counterPrice,
    this.negotiationStatus,
    this.isNegotiated = false,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

  Map<String, dynamic> toJson() => _$BookingToJson(this);
}
