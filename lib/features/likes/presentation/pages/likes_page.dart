import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/widgets/connectivity_app_bar.dart';
import '../../../../core/widgets/network_error_boundary.dart';
import '../providers/likes_provider.dart';
import '../widgets/likes_error_state.dart';
import '../widgets/likes_grid_view.dart';
import '../widgets/likes_shimmer_loading.dart';

class LikesPage extends ConsumerStatefulWidget {
  const LikesPage({super.key});

  @override
  ConsumerState<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends ConsumerState<LikesPage>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  bool _hasInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized && mounted) {
      _hasInitialized = true;
      // Track screen view
      AnalyticsService.trackScreenView('likes_page');

      // Use microtask instead of postFrameCallback for immediate execution
      Future.microtask(() {
        if (mounted) {
          ref.read(likesProvider.notifier).loadAllLikes();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final likesState = ref.watch(likesProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return NetworkErrorBoundary(
      fallbackMessage:
          'Likes data is cached and will sync when you\'re back online. You can still view your likes and matches.',
      onRetry: () async {
        await ref.read(likesProvider.notifier).loadAllLikes();
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
        appBar: ConnectivityAppBar(
          title: 'HeartLink',
          showConnectivityIndicator: true,
          onRefresh: () async {
            ref.read(likesProvider.notifier).loadAllLikes();
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildTinderTabBar(likesState, isDarkMode),
              SizedBox(height: 10.h),
              Expanded(child: _buildContent(likesState)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTinderTabBar(likesState, isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _TinderTab(
              label: '${likesState.receivedLikes.length} Likes',
              index: 0,
              isSelected: _selectedIndex == 0,
              isDarkMode: isDarkMode,
              onTap: (index) {
                if (_selectedIndex != index) {
                  // Track tab switch
                  AnalyticsService.trackFeatureUsage(
                    featureName: 'likes_tab_switch',
                    parameters: {
                      'from_tab': _selectedIndex == 0 ? 'received' : 'sent',
                      'to_tab': index == 0 ? 'received' : 'sent',
                    },
                  );
                  setState(() => _selectedIndex = index);
                }
              },
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _TinderTab(
              label: '${likesState.sentLikes.length} Sent',
              index: 1,
              isSelected: _selectedIndex == 1,
              isDarkMode: isDarkMode,
              onTap: (index) {
                if (_selectedIndex != index) {
                  // Track tab switch
                  AnalyticsService.trackFeatureUsage(
                    featureName: 'likes_tab_switch',
                    parameters: {
                      'from_tab': _selectedIndex == 0 ? 'received' : 'sent',
                      'to_tab': index == 0 ? 'received' : 'sent',
                    },
                  );
                  setState(() => _selectedIndex = index);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(likesState) {
    if (likesState.isLoading) {
      return const LikesShimmerLoading();
    }

    if (likesState.error != null) {
      return LikesErrorState(
        error: likesState.error!,
        onRetry: () {
          ref.read(likesProvider.notifier).loadAllLikes();
        },
      );
    }

    final likes = _selectedIndex == 0
        ? likesState.receivedLikes
        : likesState.sentLikes;

    return Column(
      children: [
        Expanded(
          child: LikesGridView(likes: likes, isReceived: _selectedIndex == 0),
        ),
      ],
    );
  }
}

class _TinderTab extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final bool isDarkMode;
  final ValueChanged<int> onTap;

  const _TinderTab({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text(
              label,
              style: appStyle(
                17.sp,
                isSelected
                    ? (isDarkMode ? Colors.white : Colors.black)
                    : AppColors.greyShade500,
                FontWeight.w500,
              ).copyWith(letterSpacing: -0.3),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: 3.h,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDarkMode ? Colors.white : Colors.black)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
