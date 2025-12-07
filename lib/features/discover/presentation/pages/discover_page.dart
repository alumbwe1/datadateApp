import 'package:datadate/core/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRecommendedProfiles();
      });
    }
  }

  Future<void> _loadRecommendedProfiles() async {
    await ref.read(discoverProvider.notifier).loadRecommendedProfiles();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final discoverState = ref.watch(discoverProvider);
    final profiles = discoverState.profiles;

    return Scaffold(
      backgroundColor: Colors.white,
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
          ? _buildErrorState(discoverState.error!)
          : profiles.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    children: [
                      Text(
                        'Featured profiles picked just for you',
                        textAlign: TextAlign.center,
                        style: appStyle(
                          14,
                          Colors.grey.shade600,
                          FontWeight.w400,
                        ).copyWith(height: 1.4),
                      ),
                    ],
                  ),
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

  Widget _buildEmptyState() {
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
                color: Colors.grey[100],
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
                Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Check back soon for new\nrecommended profiles',
              style: appStyle(
                16,
                Colors.grey[600]!,
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
                'Refresh',
                style: appStyle(16, Colors.white, FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
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
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.error_outline, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Oops!',
              style: appStyle(
                28,
                Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: appStyle(
                16,
                Colors.grey[600]!,
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
    return GestureDetector(
      onTap: () async {
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
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              CachedNetworkImage(
                imageUrl: profile.photos.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  ),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.5, 0.75, 1.0],
                  ),
                ),
              ),

              // Online indicator

              // Profile info (bottom)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${profile.displayName}, ${profile.age}',
                        style: appStyle(17, Colors.white, FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.school,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              profile.universityName,
                              style: appStyle(
                                12,
                                Colors.white.withValues(alpha: 0.9),
                                FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.heart, size: 17, color: Colors.black),
                            Text(
                              'Here for ${profile.intent}',
                              style: appStyle(
                                10,
                                Colors.black,
                                FontWeight.w500,
                              ),
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
            ],
          ),
        ),
      ),
    );
  }
}
