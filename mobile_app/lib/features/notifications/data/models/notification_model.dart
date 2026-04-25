import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String type;
  final String title;
  final String message;
  @JsonKey(name: 'related_id')
  final int? relatedId;
  @JsonKey(name: 'is_read', fromJson: _boolFromInt, toJson: _boolToInt)
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.relatedId,
    this.isRead = false,
    required this.createdAt,
  });

  static bool _boolFromInt(dynamic val) {
    if (val is bool) return val;
    if (val is int) return val == 1;
    if (val is String) return val == '1';
    return false;
  }

  static int _boolToInt(bool val) => val ? 1 : 0;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
