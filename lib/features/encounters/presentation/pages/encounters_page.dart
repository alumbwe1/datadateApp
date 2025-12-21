import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/encounters_provider.dart';
import '../widgets/animated_action_button.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/profile_card.dart';
import 'match_page.dart';

class EncountersPage extends ConsumerStatefulWidget {
  const EncountersPage({super.key});

  @override
  ConsumerState<EncountersPage> createState() => _EncountersPageState();
}

class _EncountersPageState extends ConsumerState<EncountersPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final CardSwiperController _controller = CardSwiperController();

  late AnimationController _swipeAnimationController;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && mounted) {
      _isInitialized = true;
      // Move async logic to provider initialization
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(encountersProvider.notifier).initializeWithUserPreference();
        }
      });
    }
  }

  Future<void> _handleSwipe(
    CardSwiperDirection direction,
    String profileId,
    String profileName,
    String profilePhoto,
  ) async {
    debugPrint(
      '👆 Swiped ${direction == CardSwiperDirection.right ? "RIGHT ❤️" : "LEFT ❌"} on $profileName (ID: $profileId)',
    );

    // Instant API call based on direction
    if (direction == CardSwiperDirection.right) {
      try {
        debugPrint('💕 Sending like to $profileName...');
        final matchInfo = await ref
            .read(encountersProvider.notifier)
            .likeProfile(profileId);

        if (mounted) {
          // Check if it's a match
          if (matchInfo != null && matchInfo['matched'] == true) {
            debugPrint('🎉 IT\'S A MATCH with $profileName!');
            // Extract room_id from match info
            final roomId = matchInfo['room_id'] as int?;

            if (roomId != null) {
              Future.delayed(const Duration(milliseconds: 400), () {
                if (mounted) {
                  _showMatchDialog(profileName, profilePhoto, roomId);
                }
              });
            }
          } else {
            debugPrint('✅ Like sent to $profileName (no match yet)');
          }
        }
      } catch (e) {
        debugPrint('❌ Error liking $profileName: $e');
        if (mounted) {
          // Handle "already liked" error
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
              message: 'Failed to send a like ',
              type: SnackbarType.error,
              duration: const Duration(seconds: 2),
            );
          }
        }
      }
    } else if (direction == CardSwiperDirection.left) {
      debugPrint('⏭️ Skipping $profileName');
      ref.read(encountersProvider.notifier).skipProfile(profileId);
    }
  }

  void _animateSwipeFeedback(bool isLike) {
    // Animation removed for performance - no visual feedback
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final encountersState = ref.watch(encountersProvider);
    final profiles = encountersState.profiles;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.h),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            child: Row(
              children: [
                // HeartLink Logo with Gradient
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.heartGradient.createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                  child: Text(
                    'HeartLink',
                    style: appStyle(
                      24.sp,
                      Colors.white,
                      FontWeight.w800,
                    ).copyWith(letterSpacing: -0.5, height: 1),
                  ),
                ),
                const Spacer(),

                // Filter Icon Button - Modern Style
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
                    icon: Icon(IconlyLight.filter, size: 20.sp),
                    color: AppColors.primaryLight,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showFilterBottomSheet();
                    },
                    splashRadius: 24,
                    padding: EdgeInsets.zero,
                  ),
                ),

                // Reels Toggle Button
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                //   decoration: BoxDecoration(
                //     border: Border.all(
                //       color: AppColors.primaryLight.withValues(alpha: 0.3),
                //       width: 1.w,
                //     ),
                //     borderRadius: BorderRadius.circular(20.r),
                //   ),
                //   child: IconButton(
                //     icon: Icon(Icons.play_circle_outline_rounded, size: 20.sp),
                //     color: AppColors.primaryLight,
                //     onPressed: () {
                //       HapticFeedback.lightImpact();
                //       Navigator.of(context).push(
                //         MaterialPageRoute(
                //           builder: (context) => const ReelsPage(),
                //           fullscreenDialog: true,
                //         ),
                //       );
                //     },
                //     splashRadius: 24,
                //     padding: EdgeInsets.zero,
                //   ),
                // ),

                //const SizedBox(width: 8),

                // // Boost Button - Premium Style with Gradient
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                //   decoration: BoxDecoration(
                //     gradient: LinearGradient(
                //       colors: [
                //         AppColors.accentLight,
                //         AppColors.accentLight.withValues(alpha: 0.8),
                //       ],
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //     ),
                //     borderRadius: BorderRadius.circular(20.sp),
                //     boxShadow: [
                //       BoxShadow(
                //         color: AppColors.accentLight.withValues(alpha: 0.3),
                //         blurRadius: 8,
                //         offset: const Offset(0, 2),
                //       ),
                //     ],
                //   ),
                //   child: IconButton(
                //     icon: Icon(
                //       Icons.bolt_rounded,
                //       size: 20.sp,
                //       color: Colors.black,
                //     ),
                //     color: Colors.white,
                //     onPressed: () {
                //       HapticFeedback.mediumImpact();
                //       _showBoostBottomSheet();
                //     },
                //     splashRadius: 24,
                //     padding: EdgeInsets.zero,
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
      body: encountersState.isLoading
          ? const Center(child: ProfileCardShimmer())
          : encountersState.error != null
          ? _buildErrorState(encountersState.error!)
          : profiles.isEmpty
          ? _buildEmptyState(encountersState.activeFilterCount > 0)
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                child: Stack(
                  children: [
                    CardSwiper(
                      controller: _controller,
                      cardsCount: profiles.length,
                      numberOfCardsDisplayed: 1,
                      backCardOffset: const Offset(0, -20),
                      padding: EdgeInsets.zero,
                      duration: const Duration(milliseconds: 200),
                      onSwipe: (previousIndex, currentIndex, direction) {
                        final profile = profiles[previousIndex];

                        if (direction == CardSwiperDirection.right) {
                          _animateSwipeFeedback(true);
                        } else if (direction == CardSwiperDirection.left) {
                          _animateSwipeFeedback(false);
                        }

                        // Safe check for photos
                        final profilePhoto = profile.photos.isNotEmpty
                            ? profile.photos.first
                            : '';

                        _handleSwipe(
                          direction,
                          profile.id.toString(),
                          profile.displayName,
                          profilePhoto,
                        );
                        return true;
                      },
                      cardBuilder: (context, index, x, y) {
                        return ProfileCard(profile: profiles[index]);
                      },
                    ),
                    Positioned(
                      bottom: 2.h,
                      left: 0,
                      right: 0,
                      child: _buildActionButtons(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              errorMessage,
              style: appStyle(
                16,
                isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                FontWeight.w400,
              ).copyWith(height: 1.5, letterSpacing: -0.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  ref
                      .read(encountersProvider.notifier)
                      .initializeWithUserPreference();
                }
              },
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

  Widget _buildEmptyState(bool hasActiveFilters) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              child: Center(
                child: Text(
                  hasActiveFilters ? '🔍' : '✨',
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              hasActiveFilters ? 'No Matches Found' : 'You\'re All Caught Up!',
              style: appStyle(
                28,
                isDarkMode ? Colors.white : Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              hasActiveFilters
                  ? 'Try adjusting your filters\nto see more profiles'
                  : 'Check back soon for new profiles\nto connect with',
              style: appStyle(
                16,
                isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                FontWeight.w400,
              ).copyWith(height: 1.5, letterSpacing: -0.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (hasActiveFilters)
              OutlinedButton(
                onPressed: () async {
                  final profile = ref.read(profileProvider).profile;
                  if (profile != null && profile.preferredGenders.isNotEmpty) {
                    final preferredGender = profile.preferredGenders.first;
                    ref
                        .read(encountersProvider.notifier)
                        .clearFilters(preferredGender);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              color: AppColors.primaryLight,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Filters cleared',
                              style: appStyle(
                                14,
                                Colors.white,
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.black87,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDarkMode ? Colors.white : Colors.black,
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Clear Filters',
                  style: appStyle(
                    16,
                    isDarkMode ? Colors.white : Colors.black,
                    FontWeight.w700,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: () {
                  if (mounted) {
                    ref
                        .read(encountersProvider.notifier)
                        .initializeWithUserPreference();
                  }
                },
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

  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSpacing = screenWidth * 0.02;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedActionButton(
            icon: Icons.replay_rounded,
            iconColor: AppColors.warning,
            size: screenWidth * 0.13,
            iconSize: screenWidth * 0.06,
            onPressed: () {
              _controller.undo();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Rewound last swipe',
                    style: appStyle(14, Colors.white, FontWeight.w600),
                  ),
                  backgroundColor: Colors.black,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          SizedBox(width: buttonSpacing),
          AnimatedActionButton(
            icon: Icons.close_rounded,
            iconColor: AppColors.nope,
            size: screenWidth * 0.18,
            iconSize: screenWidth * 0.10,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.left);
            },
          ),
          // SizedBox(width: buttonSpacing),
          // AnimatedActionButton(
          //   icon: Icons.star_rounded,
          //   iconColor: Colors.blue,
          //   size: screenWidth * 0.13,
          //   iconSize: screenWidth * 0.06,
          //   onPressed: () {
          //     _controller.swipe(CardSwiperDirection.right);
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content: Row(
          //           children: [
          //             const Icon(
          //               Icons.star_rounded,
          //               color: Colors.blue,
          //               size: 20,
          //             ),
          //             const SizedBox(width: 12),
          //             Text(
          //               'Super Like sent! ⭐',
          //               style: appStyle(14, Colors.white, FontWeight.w600),
          //             ),
          //           ],
          //         ),
          //         backgroundColor: Colors.black,
          //         behavior: SnackBarBehavior.floating,
          //         duration: const Duration(seconds: 2),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //       ),
          //     );
          //   },
          // ),
          SizedBox(width: buttonSpacing),
          AnimatedActionButton(
            icon: Iconsax.heart,
            iconColor: Colors.redAccent,
            size: screenWidth * 0.18,
            iconSize: screenWidth * 0.10,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.right);
            },
          ),

          SizedBox(width: buttonSpacing),
          AnimatedActionButton(
            icon: IconlyBold.send,
            iconColor: Colors.blue,
            size: screenWidth * 0.13,
            iconSize: screenWidth * 0.06,
            onPressed: () {
              CustomSnackbar.show(
                context,
                message: 'You can only text if it\'s a match',
                type: SnackbarType.error,
                duration: const Duration(seconds: 2),
              );

              // Delay the swipe so snackbar is visible
              Future.delayed(const Duration(milliseconds: 300), () {
                _controller.swipe(CardSwiperDirection.left);
              });
            },
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    final encountersState = ref.read(encountersProvider);
    final profile = ref.read(profileProvider).profile;

    // Get current age filters or defaults
    final currentMinAge =
        encountersState.activeFilters['minAge']?.toDouble() ?? 18.0;
    final currentMaxAge =
        encountersState.activeFilters['maxAge']?.toDouble() ?? 35.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        initialMinAge: currentMinAge,
        initialMaxAge: currentMaxAge,
        onApply: (minAge, maxAge) {
          if (profile != null && profile.preferredGenders.isNotEmpty) {
            final preferredGender = profile.preferredGenders.first;

            // Create filter map with age range
            final filters = {
              'minAge': minAge.round(),
              'maxAge': maxAge.round(),
            };

            // Apply filters through provider
            ref
                .read(encountersProvider.notifier)
                .applyFilters(filters, preferredGender);

            // Show confirmation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryLight,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Age filter: ${minAge.round()}-${maxAge.round()} years',
                      style: appStyle(14, Colors.white, FontWeight.w600),
                    ),
                  ],
                ),
                backgroundColor: Colors.black87,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // void _showBoostBottomSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     isDismissible: true,
  //     useSafeArea: true,
  //     builder: (context) => const BoostBottomSheet(),
  //   );
  // }

  void _showMatchDialog(String profileName, String profilePhoto, int roomId) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MatchPage(
          profileName: profileName,
          profilePhoto: profilePhoto,
          roomId: roomId,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _swipeAnimationController.dispose();
    super.dispose();
  }
}
