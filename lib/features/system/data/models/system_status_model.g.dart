// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SystemStatusModelImpl _$$SystemStatusModelImplFromJson(
  Map<String, dynamic> json,
) => _$SystemStatusModelImpl(
  mode: json['mode'] as String,
  isMaintenance: json['is_maintenance'] as bool,
  maintenanceMessage: json['maintenance_message'] as String,
  featuresEnabled: FeaturesEnabledModel.fromJson(
    json['features_enabled'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$$SystemStatusModelImplToJson(
  _$SystemStatusModelImpl instance,
) => <String, dynamic>{
  'mode': instance.mode,
  'is_maintenance': instance.isMaintenance,
  'maintenance_message': instance.maintenanceMessage,
  'features_enabled': instance.featuresEnabled,
};

_$FeaturesEnabledModelImpl _$$FeaturesEnabledModelImplFromJson(
  Map<String, dynamic> json,
) => _$FeaturesEnabledModelImpl(
  matching: json['matching'] as bool,
  chat: json['chat'] as bool,
  boost: json['boost'] as bool,
  premium: json['premium'] as bool,
);

Map<String, dynamic> _$$FeaturesEnabledModelImplToJson(
  _$FeaturesEnabledModelImpl instance,
) => <String, dynamic>{
  'matching': instance.matching,
  'chat': instance.chat,
  'boost': instance.boost,
  'premium': instance.premium,
};
