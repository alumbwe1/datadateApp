import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import '../providers/encounters_provider.dart';
import '../widgets/profile_card.dart';
import '../widgets/swipe_overlay.dart';
import '../widgets/animated_action_button.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/boost_bottom_sheet.dart';
import 'match_page.dart';

class EncountersPage extends ConsumerStatefulWidget {
  const EncountersPage({super.key});

  @override
  ConsumerState<EncountersPage> createState() => _EncountersPageState();
}

class _EncountersPageState extends ConsumerState<EncountersPage>
    with TickerProviderStateMixin {
  final CardSwiperController _controller = CardSwiperController();

  late AnimationController _swipeAnimationController;
  late AnimationController _breatheController;
  bool _showLikeOverlay = false;
  bool _showNopeOverlay = false;
  double _overlayOpacity = 0.0;

  // Filter state
  double _minAge = 18;
  double _maxAge = 35;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(encountersProvider.notifier).loadProfiles(user.gender);
      }
    });
  }

  void _handleSwipe(
    CardSwiperDirection direction,
    String profileId,
    String profileName,
    String profilePhoto,
  ) {
    // Instant API call based on direction
    if (direction == CardSwiperDirection.right) {
      ref.read(encountersProvider.notifier).likeProfile(profileId);

      // Check for match (simulate 30% chance for demo)
      final isMatch = DateTime.now().millisecond % 10 < 3;
      if (isMatch) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _showMatchDialog(profileName, profilePhoto);
          }
        });
      }
    } else if (direction == CardSwiperDirection.left) {
      ref.read(encountersProvider.notifier).skipProfile(profileId);
    }
  }

  void _animateSwipeFeedback(bool isLike) {
    setState(() {
      if (isLike) {
        _showLikeOverlay = true;
        _showNopeOverlay = false;
      } else {
        _showLikeOverlay = false;
        _showNopeOverlay = true;
      }
      _overlayOpacity = 1.0;
    });

    _swipeAnimationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _swipeAnimationController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showLikeOverlay = false;
                _showNopeOverlay = false;
                _overlayOpacity = 0.0;
              });
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final encountersState = ref.watch(encountersProvider);
    final profiles = encountersState.profiles;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.h),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      26,
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

                const SizedBox(width: 8),

                // Boost Button - Premium Style with Gradient
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentLight,
                        AppColors.accentLight.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.sp),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentLight.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.bolt_rounded,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                    color: Colors.white,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showBoostBottomSheet();
                    },
                    splashRadius: 24,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: encountersState.isLoading
          ? const Center(child: ProfileCardShimmer())
          : encountersState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    encountersState.error!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final user = ref.read(authProvider).user;
                      if (user != null) {
                        ref
                            .read(encountersProvider.notifier)
                            .loadProfiles(user.gender);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : profiles.isEmpty
          ? _buildEmptyState()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                child: Stack(
                  children: [
                    Stack(
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

                            _handleSwipe(
                              direction,
                              profile.id.toString(),
                              profile.displayName,
                              profile.photos.first,
                            );
                            return true;
                          },
                          cardBuilder: (context, index, x, y) {
                            return AnimatedBuilder(
                              animation: _breatheController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale:
                                      1.0 + (_breatheController.value * 0.005),
                                  child: child,
                                );
                              },
                              child: ProfileCard(profile: profiles[index]),
                            );
                          },
                        ),
                        if (_showLikeOverlay)
                          SwipeOverlay(isLike: true, opacity: _overlayOpacity),
                        if (_showNopeOverlay)
                          SwipeOverlay(isLike: false, opacity: _overlayOpacity),
                      ],
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
              'Check back soon for new profiles\nto connect with',
              style: appStyle(
                16,
                Colors.grey[600]!,
                FontWeight.w400,
              ).copyWith(height: 1.5, letterSpacing: -0.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                final user = ref.read(authProvider).user;
                if (user != null) {
                  ref
                      .read(encountersProvider.notifier)
                      .loadProfiles(user.gender);
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
                'Refresh',
                style: appStyle(16, Colors.white, FontWeight.w700),
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
          SizedBox(width: buttonSpacing),
          AnimatedActionButton(
            icon: Icons.star_rounded,
            iconColor: Colors.blue,
            size: screenWidth * 0.13,
            iconSize: screenWidth * 0.06,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.right);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Super Like sent! ⭐',
                        style: appStyle(14, Colors.white, FontWeight.w600),
                      ),
                    ],
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
              _controller.swipe(CardSwiperDirection.left);
            },
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        initialMinAge: _minAge,
        initialMaxAge: _maxAge,
        onApply: (minAge, maxAge) {
          setState(() {
            _minAge = minAge;
            _maxAge = maxAge;
          });

          // Show confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primaryLight,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filters applied: ${minAge.round()}-${maxAge.round()} years',
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

          // TODO: Reload profiles with new age filter
          // ref.read(encountersProvider.notifier).loadProfilesWithFilter(
          //   minAge: minAge.round(),
          //   maxAge: maxAge.round(),
          // );
        },
      ),
    );
  }

  void _showBoostBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const BoostBottomSheet(),
    );
  }

  void _showMatchDialog(String profileName, String profilePhoto) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MatchPage(profileName: profileName, profilePhoto: profilePhoto),
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
    _breatheController.dispose();
    super.dispose();
  }
}
