import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../features/encounters/presentation/pages/encounters_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/discover/presentation/pages/discover_page.dart';
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

    const ChatPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      4,
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
        decoration: BoxDecoration(color: Colors.white),
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
                  activeColor: Colors.black,
                ),
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Discover',
                  index: 1,
                  activeColor: Colors.black,
                ),
                _buildNavItem(
                  svgPath: 'assets/svgs/beacon.svg',
                  label: 'Chats',
                  index: 2,
                  activeColor: Colors.black,
                ),
                _buildNavItem(
                  icon: Iconsax.user,
                  label: 'Profile',
                  index: 3,
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
                      width: 22,
                      height: 22,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        isActive ? activeColor : Colors.grey.shade400,
                        BlendMode.srcIn,
                      ),
                    )
                  : Icon(
                      icon,
                      color: isActive ? activeColor : Colors.grey.shade400,
                      size: 25,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
