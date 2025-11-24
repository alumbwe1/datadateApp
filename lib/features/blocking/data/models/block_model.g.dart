// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BlockModelImpl _$$BlockModelImplFromJson(Map<String, dynamic> json) =>
    _$BlockModelImpl(
      id: (json['id'] as num).toInt(),
      blockerUsername: json['blocker_username'] as String,
      blockedUsername: json['blocked_username'] as String,
      blockedUserId: (json['blocked_user_id'] as num).toInt(),
      reason: json['reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$BlockModelImplToJson(_$BlockModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'blocker_username': instance.blockerUsername,
      'blocked_username': instance.blockedUsername,
      'blocked_user_id': instance.blockedUserId,
      'reason': instance.reason,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$BlockStatusModelImpl _$$BlockStatusModelImplFromJson(
  Map<String, dynamic> json,
) => _$BlockStatusModelImpl(
  isBlocked: json['is_blocked'] as bool,
  isBlockedBy: json['is_blocked_by'] as bool,
  canInteract: json['can_interact'] as bool,
);

Map<String, dynamic> _$$BlockStatusModelImplToJson(
  _$BlockStatusModelImpl instance,
) => <String, dynamic>{
  'is_blocked': instance.isBlocked,
  'is_blocked_by': instance.isBlockedBy,
  'can_interact': instance.canInteract,
};
