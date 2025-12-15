import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/constants/app_colors.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(likesProvider.notifier).loadAllLikes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final likesState = ref.watch(likesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            _buildHeader(),
            SizedBox(height: 20.h),
            _buildTinderTabBar(likesState),
            SizedBox(height: 10.h),
            Expanded(child: _buildContent(likesState)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'HeartLink',
            style: appStyle(
              24.sp,
              const Color(0xFFFE3C72),
              FontWeight.w900,
            ).copyWith(letterSpacing: -0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTinderTabBar(likesState) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _TinderTab(
              label: '${likesState.receivedLikes.length} Likes',
              index: 0,
              isSelected: _selectedIndex == 0,
              onTap: (index) {
                if (_selectedIndex != index) {
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
              onTap: (index) {
                if (_selectedIndex != index) {
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
  final ValueChanged<int> onTap;

  const _TinderTab({
    required this.label,
    required this.index,
    required this.isSelected,
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
                isSelected ? Colors.black : AppColors.greyShade500,
                FontWeight.w500,
              ).copyWith(letterSpacing: -0.3),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: 3.h,
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}
