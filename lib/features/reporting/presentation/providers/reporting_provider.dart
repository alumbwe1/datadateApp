import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/reporting_remote_datasource.dart';
import '../../data/models/report_model.dart';

final reportingDataSourceProvider = Provider<ReportingRemoteDataSource>((ref) {
  return ReportingRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final myReportsProvider =
    StateNotifierProvider<MyReportsNotifier, AsyncValue<List<ReportModel>>>(
      (ref) =>
          MyReportsNotifier(dataSource: ref.watch(reportingDataSourceProvider)),
    );

class MyReportsNotifier extends StateNotifier<AsyncValue<List<ReportModel>>> {
  final ReportingRemoteDataSource dataSource;

  MyReportsNotifier({required this.dataSource})
    : super(const AsyncValue.loading()) {
    fetchMyReports();
  }

  Future<void> fetchMyReports() async {
    state = const AsyncValue.loading();
    try {
      final reports = await dataSource.getMyReports();
      state = AsyncValue.data(reports);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createReport({
    required int reportedUserId,
    required String reportType,
    required String reason,
    String? description,
    String? messageId,
  }) async {
    try {
      final report = await dataSource.createReport(
        reportedUserId: reportedUserId,
        reportType: reportType,
        reason: reason,
        description: description,
        messageId: messageId,
      );

      final currentReports = state.value ?? [];
      state = AsyncValue.data([report, ...currentReports]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
