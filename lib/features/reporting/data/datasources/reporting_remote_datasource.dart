import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/report_model.dart';

abstract class ReportingRemoteDataSource {
  Future<ReportModel> createReport({
    required int reportedUserId,
    required String reportType,
    required String reason,
    String? description,
    String? messageId,
  });
  Future<List<ReportModel>> getMyReports();
}

class ReportingRemoteDataSourceImpl implements ReportingRemoteDataSource {
  final ApiClient apiClient;

  ReportingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ReportModel> createReport({
    required int reportedUserId,
    required String reportType,
    required String reason,
    String? description,
    String? messageId,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.reports,
      data: {
        'reported_user_id': reportedUserId,
        'report_type': reportType,
        'reason': reason,
        if (description != null) 'description': description,
        if (messageId != null) 'message_id': messageId,
      },
    );
    return ReportModel.fromJson(response.data['report']);
  }

  @override
  Future<List<ReportModel>> getMyReports() async {
    final response = await apiClient.get(ApiEndpoints.myReports);
    return (response.data as List)
        .map((json) => ReportModel.fromJson(json))
        .toList();
  }
}
