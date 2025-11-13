import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../features/encounters/presentation/pages/encounters_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
import '../../features/likes/presentation/pages/likes_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _animationControllers;

  final List<Widget> _pages = [
    const EncountersPage(),
    const DiscoverPage(),
    const LikesPage(),
    const ChatPage(),
    const ProfilePage(),
  ];

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
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
                  label: 'Encounters',
                  index: 0,
                  activeColor: Colors.black,
                ),
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Discover',
                  index: 1,
                  activeColor: Colors.black,
                ),
                _buildNavItem(
                  icon: Iconsax.heart,
                  label: 'Likes',
                  index: 2,
                  activeColor: Colors.black,
                ),
                _buildNavItem(
                  icon: Iconsax.message,
                  label: 'Chats',
                  index: 3,
                  activeColor: Colors.black,
                ),
                _buildNavItem(
                  icon: Iconsax.user,
                  label: 'Profile',
                  index: 4,
                  activeColor: Colors.black,
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

    return Expanded(
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        splashColor: activeColor.withValues(alpha: 0.1),
        highlightColor: activeColor.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (animation.value * 0.15),
                    child: child,
                  );
                },
                child: svgPath != null
                    ? SvgPicture.asset(
                        svgPath,
                        width: 26,
                        height: 26,
                        colorFilter: ColorFilter.mode(
                          isActive ? activeColor : Colors.grey.shade400,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(
                        icon,
                        color: isActive ? activeColor : Colors.grey.shade400,
                        size: 26,
                      ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isActive ? 12 : 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeColor : Colors.grey.shade500,
                  letterSpacing: -0.2,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
