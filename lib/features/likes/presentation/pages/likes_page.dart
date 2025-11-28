import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';
import '../providers/likes_provider.dart';
import '../widgets/likes_grid_view.dart';
import '../widgets/likes_error_state.dart';
import '../widgets/likes_shimmer_loading.dart';

class LikesPage extends ConsumerStatefulWidget {
  const LikesPage({super.key});

  @override
  ConsumerState<LikesPage> createState() => _LikesPageState();
}

class _LikesPageState extends ConsumerState<LikesPage>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  bool _hasLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Don't load immediately - wait for first build
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load only once when page becomes visible
    if (!_hasLoaded) {
      _hasLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(likesProvider.notifier).loadAllLikes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final likesState = ref.watch(likesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Likes',
              style: appStyle(26.sp, Colors.black, FontWeight.w800),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSegmentedControl(likesState),
          SizedBox(height: 5.h),
          Expanded(child: _buildContent(likesState)),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(likesState) {
    return Center(
      child: Container(
        width: 280.w,
        height: 48.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            _buildSegment('Received', 0, likesState.receivedLikes.length),
            _buildSegment('Sent', 1, likesState.sentLikes.length),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment(String text, int index, int count) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(21.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: appStyle(
                  15.sp,
                  isSelected ? Colors.black : Colors.grey[600]!,
                  isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              SizedBox(width: 6.w),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$count',
                  style: appStyle(
                    12.sp,
                    isSelected ? Colors.white : Colors.grey[700]!,
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
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

    return LikesGridView(likes: likes, isReceived: _selectedIndex == 0);
  }
}
