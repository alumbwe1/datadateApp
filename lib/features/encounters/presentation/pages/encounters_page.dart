import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/loading_shimmer.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'DataDate',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ).copyWith(letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              final user = ref.read(authProvider).user;
              if (user != null) {
                ref.read(encountersProvider.notifier).loadProfiles(user.gender);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () {},
          ),
        ],
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
