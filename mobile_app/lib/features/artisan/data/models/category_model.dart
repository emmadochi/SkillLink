import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String? icon;
  @JsonKey(name: 'is_technical', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool isTechnical;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.isTechnical = false,
  });

  static bool _boolFromInt(dynamic val) => val == 1 || val == true;
  static int _boolToInt(bool val) => val ? 1 : 0;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
