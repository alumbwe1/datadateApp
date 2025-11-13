import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/constants/app_style.dart';
import '../providers/encounters_provider.dart';
import '../widgets/profile_card.dart';

class EncountersPage extends ConsumerStatefulWidget {
  const EncountersPage({super.key});

  @override
  ConsumerState<EncountersPage> createState() => _EncountersPageState();
}

class _EncountersPageState extends ConsumerState<EncountersPage> {
  final CardSwiperController _controller = CardSwiperController();

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

  @override
  Widget build(BuildContext context) {
    final encountersState = ref.watch(encountersProvider);
    final profiles = encountersState.profiles;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/dataDate.png',
                  height: 25,
                  width: 25,
                  fit: BoxFit.cover,
                  color: Colors.black,
                ),
                const SizedBox(width: 4),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 24),
                  const Text(
                    'No more profiles',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check back later for new matches',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: CardSwiper(
                  controller: _controller,
                  cardsCount: profiles.length,
                  numberOfCardsDisplayed: 2,
                  backCardOffset: const Offset(0, -20),
                  padding: EdgeInsets.zero,
                  onSwipe: (previousIndex, currentIndex, direction) {
                    final profile = profiles[previousIndex];

                    if (direction == CardSwiperDirection.right) {
                      ref
                          .read(encountersProvider.notifier)
                          .likeProfile(profile.id);
                    } else if (direction == CardSwiperDirection.left) {
                      ref
                          .read(encountersProvider.notifier)
                          .skipProfile(profile.id);
                    }

                    return true;
                  },
                  cardBuilder:
                      (context, index, percentThresholdX, percentThresholdY) {
                        return Stack(
                          children: [
                            ProfileCard(profile: profiles[index]),
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: _buildActionButtons(),
                            ),
                          ],
                        );
                      },
                ),
              ),
            ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: Colors.black,
            size: 65,
            iconSize: 35,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.left);
            },
          ),
          _buildActionButton(
            icon: Iconsax.heart,
            color: Colors.black,
            size: 65,
            iconSize: 35,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.right);
            },
          ),
          _buildActionButton(
            icon: Iconsax.star,
            color: Colors.lightGreenAccent,
            size: 65,
            iconSize: 35,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.right);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required double size,
    required double iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Center(
            child: Icon(icon, color: color, size: iconSize),
          ),
        ),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                        Icon(
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
                              'Tired of broke girlfriends or boyfriends? Meet Zambia’s elite only',
                              'Match with verified rich singles',
                              'VIP badge on your profile',
                              'Top priority in search results',
                              'Access the exclusive rich community',
                            ])
                      .map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            spacing: 12,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.black,
                                size: 24,
                              ),

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
                      ),
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
