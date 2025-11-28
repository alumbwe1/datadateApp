import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_model.freezed.dart';
part 'report_model.g.dart';

@freezed
class ReportModel with _$ReportModel {
  const factory ReportModel({
    required int id,
    required String reporterUsername,
    required String reportedUsername,
    required String reportType,
    required String reason,
    String? description,
    @JsonKey(name: 'message_id') String? messageId,
    required String status,
    @JsonKey(name: 'admin_notes') String? adminNotes,
    @JsonKey(name: 'resolved_at') DateTime? resolvedAt,
    @JsonKey(name: 'resolved_by_username') String? resolvedByUsername,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ReportModel;

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);
}
