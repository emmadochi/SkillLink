import 'package:json_annotation/json_annotation.dart';

part 'review_model.g.dart';

@JsonSerializable()
class Review {
  final int id;
  @JsonKey(name: 'booking_id')
  final int bookingId;
  @JsonKey(name: 'customer_id')
  final int customerId;
  @JsonKey(name: 'artisan_id')
  final int artisanId;
  final int rating;
  final String? comment;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'customer_name')
  final String? customerName;
  @JsonKey(name: 'customer_avatar')
  final String? customerAvatar;

  Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.artisanId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.customerName,
    this.customerAvatar,
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
