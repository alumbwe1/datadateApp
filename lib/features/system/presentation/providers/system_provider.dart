import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/api_providers.dart';
import '../../data/datasources/system_remote_datasource.dart';
import '../../data/models/system_status_model.dart';

final systemDataSourceProvider = Provider<SystemRemoteDataSource>((ref) {
  return SystemRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final systemStatusProvider =
    StateNotifierProvider<SystemStatusNotifier, AsyncValue<SystemStatusModel>>(
      (ref) =>
          SystemStatusNotifier(dataSource: ref.watch(systemDataSourceProvider)),
    );

class SystemStatusNotifier
    extends StateNotifier<AsyncValue<SystemStatusModel>> {
  final SystemRemoteDataSource dataSource;

  SystemStatusNotifier({required this.dataSource})
    : super(const AsyncValue.loading()) {
    fetchSystemStatus();
  }

  Future<void> fetchSystemStatus() async {
    state = const AsyncValue.loading();
    try {
      final status = await dataSource.getSystemStatus();
      state = AsyncValue.data(status);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  bool get isMaintenanceMode {
    return state.value?.isMaintenance ?? false;
  }

  bool get isFeatureEnabled {
    final features = state.value?.featuresEnabled;
    return features?.matching ?? false;
  }

  bool get isChatEnabled {
    return state.value?.featuresEnabled.chat ?? false;
  }

  bool get isBoostEnabled {
    return state.value?.featuresEnabled.boost ?? false;
  }

  bool get isPremiumEnabled {
    return state.value?.featuresEnabled.premium ?? false;
  }
}
