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
  }

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
          // Tinder flame icon
          Image.asset(
            'assets/images/HeartLink1.png',
            width: 34.w,
            height: 34.h,
            color: const Color(0xFFFE3C72),
          ),
          SizedBox(width: 4.w),
          Text(
            'HeartLink',
            style: appStyle(
              24.sp,
              const Color(0xFFFE3C72),
              FontWeight.w700,
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
            child: _buildTinderTab(
              '${likesState.receivedLikes.length} Likes',
              0,
            ),
          ),
          SizedBox(width: 1),
          Expanded(
            child: _buildTinderTab('${likesState.sentLikes.length} Sent', 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTinderTab(String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          setState(() => _selectedIndex = index);
        }
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Text(
              label,
              style: appStyle(
                17.sp,
                isSelected ? Colors.black : Colors.grey.shade500,
                isSelected ? FontWeight.w500 : FontWeight.w500,
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
