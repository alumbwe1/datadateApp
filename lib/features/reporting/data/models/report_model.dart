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
    String? messageId,
    required String status,
    required String? adminNotes,
    required DateTime? resolvedAt,
    required String? resolvedByUsername,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ReportModel;

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);
}
