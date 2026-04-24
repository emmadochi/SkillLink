import 'package:json_annotation/json_annotation.dart';
import '../../../auth/data/models/user_model.dart';

part 'artisan_model.g.dart';

@JsonSerializable()
class Artisan {
  @JsonKey(name: 'user_id', fromJson: _toInt)
  final int userId;
  final String? bio;
  @JsonKey(name: 'experience_years', fromJson: _toInt)
  final int experienceYears;
  @JsonKey(name: 'category_id', fromJson: _toInt)
  final int? categoryId;
  @JsonKey(name: 'average_rating', fromJson: _toDouble)
  final double rating;

  static int _toInt(dynamic val) => val is String ? (int.tryParse(val) ?? 0) : (val as int? ?? 0);
  static double _toDouble(dynamic val) => val is String ? (double.tryParse(val) ?? 0.0) : (val is int ? val.toDouble() : (val as double? ?? 0.0));
  static bool _toBool(dynamic val) => val is bool ? val : (val == 1 || val == '1' || val == 'true');
  @JsonKey(name: 'location_name')
  final String? locationName;
  @JsonKey(name: 'business_address')
  final String? businessAddress;
  @JsonKey(name: 'guarantor_name')
  final String? guarantorName;
  @JsonKey(name: 'guarantor_phone')
  final String? guarantorPhone;
  @JsonKey(name: 'identity_verified', fromJson: _toBool)
  final bool identityVerified;
  @JsonKey(name: 'identity_status')
  final String? identityStatus;
  @JsonKey(name: 'is_available', fromJson: _toBool)
  final bool isAvailable;
  final String? skill;
  @JsonKey(name: 'hourly_rate', fromJson: _toDouble)
  final double hourlyRate;
  @JsonKey(name: 'user')
  final ArtisanMiniUser? user; // Use specialized mini-user to avoid full profile mapping
  final List<PortfolioItem>? portfolio;

  Artisan({
    required this.userId,
    this.bio,
    this.experienceYears = 0,
    this.categoryId,
    this.rating = 0.0,
    this.locationName,
    this.businessAddress,
    this.guarantorName,
    this.guarantorPhone,
    this.identityVerified = false,
    this.identityStatus,
    this.isAvailable = true,
    this.skill,
    this.hourlyRate = 0.0,
    this.user,
    this.portfolio,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) => _$ArtisanFromJson(json);

  Map<String, dynamic> toJson() => _$ArtisanToJson(this);
}

@JsonSerializable()
class ArtisanMiniUser {
  final int id;
  final String name;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  ArtisanMiniUser({required this.id, required this.name, this.avatarUrl});

  factory ArtisanMiniUser.fromJson(Map<String, dynamic> json) => _$ArtisanMiniUserFromJson(json);
  Map<String, dynamic> toJson() => _$ArtisanMiniUserToJson(this);
}

@JsonSerializable()
class PortfolioItem {
  final int id;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  final String? description;

  PortfolioItem({
    required this.id,
    required this.imageUrl,
    this.description,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) => _$PortfolioItemFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioItemToJson(this);
}
