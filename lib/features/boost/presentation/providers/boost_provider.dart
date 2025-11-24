import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/boost_remote_datasource.dart';
import '../../data/models/boost_model.dart';
import '../../../../core/providers/api_providers.dart';

final boostDataSourceProvider = Provider<BoostRemoteDataSource>((ref) {
  return BoostRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final boostPricingProvider = FutureProvider.autoDispose<BoostPricingModel>((
  ref,
) async {
  final dataSource = ref.watch(boostDataSourceProvider);
  return await dataSource.getBoostPricing();
});

final activeBoostProvider =
    StateNotifierProvider<ActiveBoostNotifier, AsyncValue<BoostModel?>>((ref) {
      return ActiveBoostNotifier(
        dataSource: ref.watch(boostDataSourceProvider),
      );
    });

class ActiveBoostNotifier extends StateNotifier<AsyncValue<BoostModel?>> {
  final BoostRemoteDataSource dataSource;

  ActiveBoostNotifier({required this.dataSource})
    : super(const AsyncValue.loading()) {
    fetchActiveBoost();
  }

  Future<void> fetchActiveBoost() async {
    state = const AsyncValue.loading();
    try {
      final boost = await dataSource.getActiveBoost();
      state = AsyncValue.data(boost);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createBoost({
    required double amountPaid,
    required int targetViews,
    required int durationHours,
  }) async {
    try {
      final boost = await dataSource.createBoost(
        amountPaid: amountPaid,
        targetViews: targetViews,
        durationHours: durationHours,
      );
      state = AsyncValue.data(boost);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> activateBoost(int boostId) async {
    try {
      final boost = await dataSource.activateBoost(boostId);
      state = AsyncValue.data(boost);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  bool get hasActiveBoost {
    final boost = state.value;
    return boost != null && boost.status == 'active';
  }

  double get progress {
    return state.value?.progressPercentage ?? 0.0;
  }

  int get timeRemaining {
    return state.value?.timeRemaining ?? 0;
  }
}

final boostHistoryProvider = FutureProvider.autoDispose<List<BoostModel>>((
  ref,
) async {
  final dataSource = ref.watch(boostDataSourceProvider);
  return await dataSource.getBoostHistory();
});
