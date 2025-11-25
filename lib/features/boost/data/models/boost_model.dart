// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'boost_model.freezed.dart';
part 'boost_model.g.dart';

@freezed
class BoostPricingModel with _$BoostPricingModel {
  const factory BoostPricingModel({
    @JsonKey(name: 'min_amount') required double minAmount,
    @JsonKey(name: 'default_duration_hours') required int defaultDurationHours,
    required String currency,
    required bool enabled,
  }) = _BoostPricingModel;

  factory BoostPricingModel.fromJson(Map<String, dynamic> json) =>
      _$BoostPricingModelFromJson(json);
}

@freezed
class BoostModel with _$BoostModel {
  const factory BoostModel({
    required int id,
    required String username,
    @JsonKey(name: 'amount_paid') required String amountPaid,
    @JsonKey(name: 'target_views') required int targetViews,
    @JsonKey(name: 'duration_hours') required int durationHours,
    @JsonKey(name: 'current_views') required int currentViews,
    required String status,
    @JsonKey(name: 'progress_percentage') required double progressPercentage,
    @JsonKey(name: 'time_remaining') required int timeRemaining,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _BoostModel;

  factory BoostModel.fromJson(Map<String, dynamic> json) =>
      _$BoostModelFromJson(json);
}
