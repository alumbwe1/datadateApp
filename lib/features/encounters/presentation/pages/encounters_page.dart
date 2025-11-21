import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/constants/app_style.dart';
import '../providers/encounters_provider.dart';
import '../widgets/profile_card.dart';
import 'match_page.dart';

class EncountersPage extends ConsumerStatefulWidget {
  const EncountersPage({super.key});

  @override
  ConsumerState<EncountersPage> createState() => _EncountersPageState();
}

class _EncountersPageState extends ConsumerState<EncountersPage> {
  final CardSwiperController _controller = CardSwiperController();
  int _swipeCount = 0;
  final int _freeSwipeLimit = 3;
  bool _hasShownUpgradePrompt = false;

  @override
  void initState() {
    super.initState();
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
    setState(() {
      _swipeCount++;
    });

    // Check for match (simulate 30% chance for demo) - only on right swipe
    if (direction == CardSwiperDirection.right) {
      final isMatch = DateTime.now().millisecond % 10 < 3; // 30% chance
      if (isMatch) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showMatchDialog(profileName, profilePhoto);
          }
        });
      }
    }

    // Show upgrade prompt after 5 swipes (any direction)
    if (_swipeCount >= _freeSwipeLimit && !_hasShownUpgradePrompt) {
      _hasShownUpgradePrompt = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showUpgradePrompt();
        }
      });
    }
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
                Text(
                  'DataDate',
                  style: appStyle(
                    25,
                    Colors.black,
                    FontWeight.w800,
                  ).copyWith(letterSpacing: -0.3),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _showPremiumBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Iconsax.diamonds,
                        color: Colors.purpleAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Upgrade',
                        style: appStyle(
                          13,
                          Colors.white,
                          FontWeight.w600,
                        ).copyWith(letterSpacing: -0.3),
                      ),
                    ],
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
          ? Center(
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
            )
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
                      onSwipe: (previousIndex, currentIndex, direction) {
                        final profile = profiles[previousIndex];

                        if (direction == CardSwiperDirection.right) {
                          ref
                              .read(encountersProvider.notifier)
                              .likeProfile(profile.id.toString());
                        } else if (direction == CardSwiperDirection.left) {
                          ref
                              .read(encountersProvider.notifier)
                              .skipProfile(profile.id.toString());
                        }

                        _handleSwipe(
                          direction,
                          profile.id.toString(),
                          profile.displayName,
                          profile.photos.first,
                        );
                        return true;
                      },
                      cardBuilder:
                          (
                            context,
                            index,
                            percentThresholdX,
                            percentThresholdY,
                          ) {
                            return ProfileCard(profile: profiles[index]);
                          },
                    ),
                    // Action buttons on top of the card swiper
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

  Widget _buildActionButtons() {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSpacing = screenWidth * 0.02; // 2% of screen width

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rewind button
          _AnimatedActionButton(
            icon: Icons.replay_rounded,
            iconColor: const Color(0xFFFFC107),
            size: screenWidth * 0.13,
            iconSize: screenWidth * 0.06,
            onPressed: () {
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

          // Pass button
          _AnimatedActionButton(
            icon: Icons.close_rounded,
            iconColor: Color(0xFFFF4458),
            size: screenWidth * 0.15,
            iconSize: screenWidth * 0.08,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.left);
            },
          ),
          SizedBox(width: buttonSpacing),

          // Like button (larger)
          _AnimatedActionButton(
            icon: Iconsax.heart,
            iconColor: Colors.redAccent,
            size: screenWidth * 0.18,
            iconSize: screenWidth * 0.10,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.right);
            },
          ),
          SizedBox(width: buttonSpacing),

          // Super Like button
          _AnimatedActionButton(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFF2196F3),
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

          _AnimatedActionButton(
            icon: IconlyBold.send,
            iconColor: Color(0xFF9B59FF),
            size: screenWidth * 0.15,
            iconSize: screenWidth * 0.08,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.left);
            },
          ),
        ],
      ),
    );
  }

  void _showPremiumBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _PremiumBottomSheet(),
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

  void _showUpgradePrompt() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Premium icon with gradient background
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.purpleAccent.withOpacity(0.1),
                              Colors.deepPurpleAccent.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Iconsax.diamonds,
                            color: Colors.purpleAccent,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Title
                      Text(
                        'Out of Swipes!',
                        style: appStyle(
                          30,
                          Colors.black,
                          FontWeight.w900,
                        ).copyWith(letterSpacing: -0.8),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),

                      // Description
                      Text(
                        'Upgrade to Standard for unlimited swipes\nand exclusive features',
                        style: appStyle(
                          15,
                          Colors.grey[600]!,
                          FontWeight.w500,
                        ).copyWith(height: 1.6, letterSpacing: -0.2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Upgrade button with gradient
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black, Colors.grey[900]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showPremiumBottomSheet(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Upgrade Now',
                            style: appStyle(
                              16,
                              Colors.white,
                              FontWeight.w700,
                            ).copyWith(letterSpacing: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Maybe later button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                        ),
                        child: Text(
                          'Maybe Later',
                          style: appStyle(
                            15,
                            Colors.grey[600]!,
                            FontWeight.w600,
                          ),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final double size;
  final double iconSize;
  final VoidCallback onPressed;

  const _AnimatedActionButton({
    required this.icon,
    required this.iconColor,
    required this.size,
    required this.iconSize,
    required this.onPressed,
  });

  @override
  State<_AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            // Outer soft glow
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),

            // Inner glossy light
            BoxShadow(
              color: Colors.white.withOpacity(0.12),
              blurRadius: 4,
              spreadRadius: -2,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            splashColor: widget.iconColor.withOpacity(0.25),
            highlightColor: widget.iconColor.withOpacity(0.10),
            onTap: _handleTap,
            child: Center(
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: widget.iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumBottomSheet extends StatefulWidget {
  const _PremiumBottomSheet();

  @override
  State<_PremiumBottomSheet> createState() => _PremiumBottomSheetState();
}

class _PremiumBottomSheetState extends State<_PremiumBottomSheet> {
  bool _isStandard = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              children: [
                Text(
                  'Upgrade Plan',
                  style: appStyle(
                    24,
                    Colors.black,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: -0.3),
                ),
                const SizedBox(height: 16),
                Container(
                  width: MediaQuery.of(context).size.width * 0.48,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isStandard = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: _isStandard
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Standard',
                              textAlign: TextAlign.center,
                              style: appStyle(
                                15,
                                _isStandard ? Colors.white : Colors.black,
                                FontWeight.w600,
                              ).copyWith(letterSpacing: -0.3),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isStandard = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: !_isStandard
                                  ? Colors.black
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Premium',
                              textAlign: TextAlign.center,
                              style: appStyle(
                                15,
                                !_isStandard ? Colors.white : Colors.black,
                                FontWeight.w600,
                              ).copyWith(letterSpacing: -0.3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _isStandard ? 'Standard' : 'Premium',
                        style: appStyle(
                          32,
                          Colors.black,
                          FontWeight.w900,
                        ).copyWith(letterSpacing: -0.3),
                      ),
                      if (!_isStandard) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, size: 24),
                        const SizedBox(width: 4),
                        const Icon(
                          Iconsax.diamonds,
                          color: Colors.purpleAccent,
                          size: 24,
                        ),
                      ],
                    ],
                  ),
                  if (!_isStandard) ...[
                    const SizedBox(height: 4),
                    Text(
                      'For Rich Kids',
                      style: appStyle(
                        14,
                        Colors.grey[600]!,
                        FontWeight.w500,
                      ).copyWith(letterSpacing: -0.3),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _isStandard ? 'K10' : 'K100',
                        style: appStyle(48, Colors.black, FontWeight.bold),
                      ),
                      Text(
                        '/week',
                        style: appStyle(16, Colors.grey[600]!, FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ...(_isStandard
                          ? [
                              'Unlimited swipes',
                              'See who likes you',
                              'Rewind last swipe',
                              '5 Super Likes per day',
                            ]
                          : [
                              'Everything in Standard',
                              'Unlimited Super Likes',
                              'Tired of broke girlfriends or boyfriends? Meet Zambia\'s elite only',
                              'Match with verified rich singles',
                              'VIP badge on your profile',
                              'Top priority in search results',
                              'Access the exclusive rich community',
                            ])
                      .map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: appStyle(
                                    15,
                                    Colors.black87,
                                    FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${_isStandard ? "Standard" : "Premium"} plan activated!',
                              style: appStyle(
                                14,
                                Colors.white,
                                FontWeight.w600,
                              ),
                            ),
                            backgroundColor: Colors.black,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: Text(
                        'Subscribe Now',
                        style: appStyle(16, Colors.white, FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cancel anytime • Secure payment',
                    style: appStyle(
                      12,
                      Colors.grey[500]!,
                      FontWeight.w400,
                    ).copyWith(letterSpacing: -0.2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
