import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_service_model.freezed.dart';
part 'category_service_model.g.dart';

@freezed
class CategoryService with _$CategoryService {
  const factory CategoryService({
    required int id,
    @JsonKey(name: 'category_id') required int categoryId,
    @JsonKey(name: 'service_name') required String name,
    @JsonKey(name: 'icon_name') String? iconName,
  }) = _CategoryService;

  factory CategoryService.fromJson(Map<String, dynamic> json) => _$CategoryServiceFromJson(json);
}
