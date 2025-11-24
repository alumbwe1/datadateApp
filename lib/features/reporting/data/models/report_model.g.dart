// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportModelImpl _$$ReportModelImplFromJson(Map<String, dynamic> json) =>
    _$ReportModelImpl(
      id: (json['id'] as num).toInt(),
      reporterUsername: json['reporter_username'] as String,
      reportedUsername: json['reported_username'] as String,
      reportType: json['report_type'] as String,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      messageId: json['message_id'] as String?,
      status: json['status'] as String,
      adminNotes: json['admin_notes'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      resolvedByUsername: json['resolved_by_username'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ReportModelImplToJson(_$ReportModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reporter_username': instance.reporterUsername,
      'reported_username': instance.reportedUsername,
      'report_type': instance.reportType,
      'reason': instance.reason,
      'description': instance.description,
      'message_id': instance.messageId,
      'status': instance.status,
      'admin_notes': instance.adminNotes,
      'resolved_at': instance.resolvedAt?.toIso8601String(),
      'resolved_by_username': instance.resolvedByUsername,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
