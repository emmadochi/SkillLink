import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  final String role;
  @JsonKey(name: 'phone', defaultValue: '')
  final String? phone;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @JsonKey(name: 'is_verified', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool isVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
    this.isVerified = false,
  });

  static bool _boolFromInt(dynamic val) {
    if (val is bool) return val;
    if (val is int) return val == 1;
    if (val is String) return val == '1';
    return false;
  }

  static int _boolToInt(bool val) => val ? 1 : 0;


  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
