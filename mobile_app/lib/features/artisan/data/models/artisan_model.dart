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
  final String? skill;
  final User? user; // Optional join data

  Artisan({
    required this.userId,
    this.bio,
    this.experienceYears = 0,
    this.rating = 0.0,
    this.locationName,
    this.skill,
    this.user,
  });

  factory Artisan.fromJson(Map<String, dynamic> json) => _$ArtisanFromJson(json);

  Map<String, dynamic> toJson() => _$ArtisanToJson(this);
}
