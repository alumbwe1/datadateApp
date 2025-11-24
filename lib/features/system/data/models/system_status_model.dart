import 'package:freezed_annotation/freezed_annotation.dart';

part 'system_status_model.freezed.dart';
part 'system_status_model.g.dart';

@freezed
class SystemStatusModel with _$SystemStatusModel {
  const factory SystemStatusModel({
    required String mode,
    @JsonKey(name: 'is_maintenance') required bool isMaintenance,
    @JsonKey(name: 'maintenance_message') required String maintenanceMessage,
    @JsonKey(name: 'features_enabled')
    required FeaturesEnabledModel featuresEnabled,
  }) = _SystemStatusModel;

  factory SystemStatusModel.fromJson(Map<String, dynamic> json) =>
      _$SystemStatusModelFromJson(json);
}

@freezed
class FeaturesEnabledModel with _$FeaturesEnabledModel {
  const factory FeaturesEnabledModel({
    required bool matching,
    required bool chat,
    required bool boost,
    required bool premium,
  }) = _FeaturesEnabledModel;

  factory FeaturesEnabledModel.fromJson(Map<String, dynamic> json) =>
      _$FeaturesEnabledModelFromJson(json);
}
