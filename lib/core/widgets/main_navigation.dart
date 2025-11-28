import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../features/encounters/presentation/pages/encounters_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
import '../../features/likes/presentation/pages/likes_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../constants/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _animationControllers;

  // Track which pages have been visited
  final Set<int> _visitedPages = {0}; // Start with encounters page

  // Build pages lazily
  Widget _buildPage(int index) {
    if (!_visitedPages.contains(index)) {
      return const SizedBox.shrink(); // Empty widget for unvisited pages
    }

    switch (index) {
      case 0:
        return const EncountersPage();
      case 1:
        return const DiscoverPage();
      case 2:
        return const LikesPage();
      case 3:
        return const ChatPage();
      case 4:
        return const ProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      5,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _animationControllers[0].value = 1.0;
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      HapticFeedback.lightImpact();
      setState(() {
        _animationControllers[_currentIndex].reverse();
        _currentIndex = index;
        _animationControllers[index].forward();
        // Mark page as visited so it gets built
        _visitedPages.add(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(5, (index) => _buildPage(index)),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.local_fire_department,
                  svgPath: 'assets/svgs/star5.svg',
                  label: 'Encounters',
                  index: 0,
                  activeColor: isDark
                      ? AppColors.navEncountersDark
                      : Colors.pink,
                ),
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Discover',
                  index: 1,
                  activeColor: isDark ? AppColors.navDiscoverDark : Colors.pink,
                ),
                _buildNavItem(
                  icon: Iconsax.heart,

                  label: 'Likes',
                  index: 2,
                  activeColor: isDark ? AppColors.navLikesDark : Colors.pink,
                ),
                _buildNavItem(
                  svgPath: 'assets/svgs/beacon.svg',
                  label: 'Chats',
                  index: 3,
                  activeColor: isDark ? AppColors.navChatsDark : Colors.pink,
                ),
                _buildNavItem(
                  icon: Iconsax.user,
                  label: 'Profile',
                  index: 4,
                  activeColor: isDark ? AppColors.navProfileDark : Colors.pink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    IconData? icon,
    String? svgPath,
    required String label,
    required int index,
    required Color activeColor,
  }) {
    final isActive = _currentIndex == index;
    final animation = _animationControllers[index];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        splashColor: activeColor.withValues(alpha: 0.1),
        highlightColor: activeColor.withValues(alpha: 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (animation.value * 0.15),
                  child: Container(
                    padding: const EdgeInsets.all(8),

                    child: child,
                  ),
                );
              },
              child: svgPath != null
                  ? SvgPicture.asset(
                      svgPath,
                      width: 26,
                      height: 26,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        isActive ? activeColor : inactiveColor,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      icon,
                      color: isActive ? activeColor : inactiveColor,
                      size: 28,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
