import 'package:cached_network_image/cached_network_image.dart';
import 'package:datadate/core/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../encounters/domain/entities/profile.dart';
import '../../../encounters/presentation/pages/profile_details_page.dart';
import '../providers/discover_provider.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage>
    with AutomaticKeepAliveClientMixin {
  bool _hasLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load only once when page becomes visible
    if (!_hasLoaded) {
      _hasLoaded = true;
      // Track screen view
      AnalyticsService.trackScreenView('discover_page');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRecommendedProfiles();
      });
    }
  }

  Future<void> _loadRecommendedProfiles() async {
    // Track refresh action
    AnalyticsService.trackFeatureUsage(
      featureName: 'discover_refresh',
      parameters: {'source': 'manual_refresh'},
    );
    await ref.read(discoverProvider.notifier).loadRecommendedProfiles();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final discoverState = ref.watch(discoverProvider);
    final profiles = discoverState.profiles;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.h),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Discover Logo with Gradient (matching HeartLink style)
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.heartGradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                  child: Text(
                    'Discover',
                    style: appStyle(
                      24.sp,
                      Colors.white,
                      FontWeight.w900,
                    ).copyWith(letterSpacing: -0.5, height: 1),
                  ),
                ),
                const Spacer(),
                // Refresh Button - Modern Style
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      width: 1.w,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.refresh_rounded, size: 20.sp),
                    color: AppColors.primaryLight,
                    onPressed: _loadRecommendedProfiles,
                    splashRadius: 24,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: discoverState.isLoading
          ? const Center(child: LottieLoadingIndicator())
          : discoverState.error != null
          ? _buildErrorState(discoverState.error!, isDarkMode)
          : profiles.isEmpty
          ? _buildEmptyState(isDarkMode)
          : Column(
              children: [
                Column(
                  children: [
                    Text(
                      'Featured profiles picked just for you',
                      textAlign: TextAlign.center,
                      style: appStyle(
                        14,
                        isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        FontWeight.w400,
                      ).copyWith(height: 1.4),
                    ),
                  ],
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      return _buildProfileCard(context, profiles[index]);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('✨', style: TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'You\'re All Caught Up!',
              style: appStyle(
                28,
                isDarkMode ? Colors.white : Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Check back soon for new\nrecommended profiles',
              style: appStyle(
                16,
                isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                FontWeight.w400,
              ).copyWith(height: 1.5, letterSpacing: -0.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _loadRecommendedProfiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.white : Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Refresh',
                style: appStyle(
                  16,
                  isDarkMode ? Colors.black : Colors.white,
                  FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Something went wrong',
              style: appStyle(
                28,
                isDarkMode ? Colors.white : Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: appStyle(
                16,
                isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                FontWeight.w400,
              ).copyWith(height: 1.5, letterSpacing: -0.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _loadRecommendedProfiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Try Again',
                style: appStyle(16, Colors.white, FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, Profile profile) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () async {
        // Track profile card tap
        AnalyticsService.trackFeatureUsage(
          featureName: 'discover_profile_card_tap',
          parameters: {
            'profile_id': profile.id.toString(),
            'profile_name': profile.displayName,
            'profile_age': profile.age,
            'profile_university': profile.universityName,
            'has_shared_interests': profile.sharedInterests.isNotEmpty,
            'shared_interests_count': profile.sharedInterests.length,
          },
        );

        // Record profile view
        await ref.read(discoverProvider.notifier).recordProfileView(profile.id);

        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileDetailsPage(profile: profile),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              AppColors.primaryLight.withValues(alpha: 0.08),
              AppColors.primaryLight.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primaryLight.withValues(alpha: 0.1),
              blurRadius: 40,
              spreadRadius: -10,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Main Image with Shimmer Loading
                CachedNetworkImage(
                  imageUrl: profile.photos.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: isDarkMode
                        ? Colors.grey[800]!
                        : Colors.grey[300]!,
                    highlightColor: isDarkMode
                        ? Colors.grey[700]!
                        : Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[300]!, Colors.grey[200]!],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Premium Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),

                // Profile Information (Bottom)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name and Age
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${profile.displayName}, ${profile.age}',
                                style: appStyle(
                                  18.sp,
                                  Colors.white,
                                  FontWeight.w800,
                                ).copyWith(letterSpacing: -0.3, height: 1.2),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Verification Badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 14.sp,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8.h),

                        // University Info
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Icon(
                                Icons.school_rounded,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                profile.universityName,
                                style: appStyle(
                                  13.sp,
                                  Colors.white.withValues(alpha: 0.9),
                                  FontWeight.w500,
                                ).copyWith(letterSpacing: -0.1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10.h),

                        // Intent Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.95),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.heart,
                                size: 16.sp,
                                color: AppColors.primaryLight,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                profile.intent,
                                style: appStyle(
                                  11.sp,
                                  Colors.black,
                                  FontWeight.w600,
                                ).copyWith(letterSpacing: -0.1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Subtle Hover Effect Overlay
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () async {
                      // Track profile tap from InkWell
                      AnalyticsService.trackProfileView(
                        profileId: profile.id.toString(),
                        source: 'discover_card_inkwell',
                      );

                      await ref
                          .read(discoverProvider.notifier)
                          .recordProfileView(profile.id);
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileDetailsPage(profile: profile),
                          ),
                        );
                      }
                    },
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
