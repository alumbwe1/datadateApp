// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boost_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BoostPricingModelImpl _$$BoostPricingModelImplFromJson(
  Map<String, dynamic> json,
) => _$BoostPricingModelImpl(
  minAmount: (json['min_amount'] as num).toDouble(),
  defaultDurationHours: (json['default_duration_hours'] as num).toInt(),
  currency: json['currency'] as String,
  enabled: json['enabled'] as bool,
);

Map<String, dynamic> _$$BoostPricingModelImplToJson(
  _$BoostPricingModelImpl instance,
) => <String, dynamic>{
  'min_amount': instance.minAmount,
  'default_duration_hours': instance.defaultDurationHours,
  'currency': instance.currency,
  'enabled': instance.enabled,
};

_$BoostModelImpl _$$BoostModelImplFromJson(Map<String, dynamic> json) =>
    _$BoostModelImpl(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      amountPaid: json['amount_paid'] as String,
      targetViews: (json['target_views'] as num).toInt(),
      durationHours: (json['duration_hours'] as num).toInt(),
      currentViews: (json['current_views'] as num).toInt(),
      status: json['status'] as String,
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      timeRemaining: (json['time_remaining'] as num).toInt(),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$BoostModelImplToJson(_$BoostModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'amount_paid': instance.amountPaid,
      'target_views': instance.targetViews,
      'duration_hours': instance.durationHours,
      'current_views': instance.currentViews,
      'status': instance.status,
      'progress_percentage': instance.progressPercentage,
      'time_remaining': instance.timeRemaining,
      'started_at': instance.startedAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
