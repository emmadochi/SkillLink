import 'package:json_annotation/json_annotation.dart';
import '../../../auth/data/models/user_model.dart';

part 'artisan_model.g.dart';

@JsonSerializable()
class Artisan {
  @JsonKey(name: 'user_id')
  final int userId;
  final String? bio;
  @JsonKey(name: 'experience_years')
  final int experienceYears;
  @JsonKey(name: 'average_rating')
  final double rating;
  @JsonKey(name: 'location_name')
  final String? locationName;
  @JsonKey(name: 'business_address')
  final String? businessAddress;
  @JsonKey(name: 'guarantor_name')
  final String? guarantorName;
  @JsonKey(name: 'guarantor_phone')
  final String? guarantorPhone;
  @JsonKey(name: 'identity_verified')
  final bool identityVerified;
  @JsonKey(name: 'identity_status')
  final String? identityStatus;
  final String? skill;
  final User? user; // Optional join data
  final List<PortfolioItem>? portfolio;

  Artisan({
    required this.userId,
    this.bio,
    this.experienceYears = 0,
    this.rating = 0.0,
    this.locationName,
    this.businessAddress,
    this.guarantorName,
    this.guarantorPhone,
    this.identityVerified = false,
    this.identityStatus,
    this.skill,
    this.user,
    this.portfolio,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) => _$ArtisanFromJson(json);

  Map<String, dynamic> toJson() => _$ArtisanToJson(this);
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
