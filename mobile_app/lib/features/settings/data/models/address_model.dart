import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

@JsonSerializable()
class UserAddress {
  final int? id;
  @JsonKey(name: 'user_id')
  final int? userId;
  final String label;
  final String address;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'is_default')
  final bool isDefault;

  UserAddress({
    this.id,
    this.userId,
    required this.label,
    required this.address,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) => _$UserAddressFromJson(json);
  Map<String, dynamic> toJson() => _$UserAddressToJson(this);
}
