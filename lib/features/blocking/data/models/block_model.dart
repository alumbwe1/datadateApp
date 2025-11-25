// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'block_model.freezed.dart';
part 'block_model.g.dart';

@freezed
class BlockModel with _$BlockModel {
  const factory BlockModel({
    required int id,
    required String blockerUsername,
    @JsonKey(name: 'blocked_username') required String blockedUsername,
    @JsonKey(name: 'blocked_user_id') required int blockedUserId,
    String? reason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _BlockModel;

  factory BlockModel.fromJson(Map<String, dynamic> json) =>
      _$BlockModelFromJson(json);
}

@freezed
class BlockStatusModel with _$BlockStatusModel {
  const factory BlockStatusModel({
    @JsonKey(name: 'is_blocked') required bool isBlocked,
    @JsonKey(name: 'is_blocked_by') required bool isBlockedBy,
    @JsonKey(name: 'can_interact') required bool canInteract,
  }) = _BlockStatusModel;

  factory BlockStatusModel.fromJson(Map<String, dynamic> json) =>
      _$BlockStatusModelFromJson(json);
}
