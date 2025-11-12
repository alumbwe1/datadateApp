import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: AppBar(
        title: const Text('Encounters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final user = ref.read(authProvider).user;
              if (user != null) {
                ref.read(encountersProvider.notifier).loadProfiles(user.gender);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // Show filters
            },
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
                  Text(encountersState.error!),
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
          ? const Center(child: Text('No more profiles available'))
          : Column(
              children: [
                Expanded(
                  child: CardSwiper(
                    controller: _controller,
                    cardsCount: profiles.length,
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
                          return ProfileCard(profile: profiles[index]);
                        },
                  ),
                ),
                _buildActionButtons(),
              ],
            ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: Colors.red,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.left);
            },
          ),
          _buildActionButton(
            icon: Icons.favorite,
            color: Colors.pink,
            size: 70,
            iconSize: 35,
            onPressed: () {
              _controller.swipe(CardSwiperDirection.right);
            },
          ),
          _buildActionButton(
            icon: Icons.star,
            color: Colors.blue,
            onPressed: () {
              // Super like
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
    double size = 60,
    double iconSize = 30,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: iconSize),
        onPressed: onPressed,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
