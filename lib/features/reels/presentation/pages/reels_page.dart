import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../encounters/domain/entities/profile.dart';
import '../../../encounters/presentation/providers/encounters_provider.dart';
import '../../../encounters/presentation/pages/profile_details_page.dart';
import '../../../encounters/presentation/pages/match_page.dart';
import '../providers/reels_provider.dart';
import '../widgets/reel_video_player.dart';

class ReelsPage extends ConsumerStatefulWidget {
  const ReelsPage({super.key});

  @override
  ConsumerState<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends ConsumerState<ReelsPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reelsProvider.notifier).loadReels();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleLike(Profile profile) async {
    try {
      final matchInfo = await ref
          .read(encountersProvider.notifier)
          .likeProfile(profile.id.toString());

      if (mounted) {
        if (matchInfo != null && matchInfo['matched'] == true) {
          // Show match dialog
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MatchPage(
                    profileName: profile.displayName,
                    profilePhoto: profile.photos.isNotEmpty
                        ? profile.photos.first
                        : '',
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        } else {
          CustomSnackbar.show(
            context,
            message: 'Like sent!',
            type: SnackbarType.success,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        if (errorMessage.contains('already liked')) {
          CustomSnackbar.show(
            context,
            message: 'You\'ve already liked this profile',
            type: SnackbarType.warning,
            duration: const Duration(seconds: 2),
          );
        } else {
          CustomSnackbar.show(
            context,
            message: 'Failed to send like',
            type: SnackbarType.error,
            duration: const Duration(seconds: 2),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reelsState = ref.watch(reelsProvider);
    final profiles = reelsState.profiles;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: reelsState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : reelsState.error != null
          ? _buildErrorState(reelsState.error!)
          : profiles.isEmpty
          ? _buildEmptyState()
          : PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                // Record profile view
                ref
                    .read(reelsProvider.notifier)
                    .recordProfileView(profiles[index].id);
              },
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                return ReelVideoPlayer(
                  profile: profiles[index],
                  isActive: index == _currentIndex,
                  onLike: () => _handleLike(profiles[index]),
                  onProfileTap: () async {
                    await ref
                        .read(reelsProvider.notifier)
                        .recordProfileView(profiles[index].id);
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileDetailsPage(profile: profiles[index]),
                        ),
                      );
                    }
                  },
                );
              },
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
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.video_library_outlined,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Videos Yet',
              style: appStyle(
                28,
                Colors.white,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Check back soon for new\nvideo profiles',
              style: appStyle(
                16,
                Colors.white.withValues(alpha: 0.7),
                FontWeight.w400,
              ).copyWith(height: 1.5, letterSpacing: -0.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                ref.read(reelsProvider.notifier).loadReels();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
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
                style: appStyle(16, Colors.black, FontWeight.w700),
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
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.error_outline, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Oops!',
              style: appStyle(
                28,
                Colors.white,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: appStyle(
                16,
                Colors.white.withValues(alpha: 0.7),
                FontWeight.w400,
              ).copyWith(height: 1.5, letterSpacing: -0.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                ref.read(reelsProvider.notifier).loadReels();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
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
                style: appStyle(16, Colors.black, FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
