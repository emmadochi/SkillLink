import 'package:json_annotation/json_annotation.dart';

part 'category_service_model.g.dart';

@JsonSerializable()
class CategoryService {
  final int id;
  @JsonKey(name: 'category_id')
  final int categoryId;
  @JsonKey(name: 'service_name')
  final String name;
  @JsonKey(name: 'icon_name')
  final String? iconName;

  CategoryService({
    required this.id,
    required this.categoryId,
    required this.name,
    this.iconName,
  });

  factory CategoryService.fromJson(Map<String, dynamic> json) => _$CategoryServiceFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryServiceToJson(this);
}
