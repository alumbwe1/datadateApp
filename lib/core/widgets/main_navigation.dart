import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.local_fire_department,
                  label: 'Encounters',
                  index: 0,
                  activeColor: const Color(0xFFFF6B6B),
                ),
                _buildNavItem(
                  icon: IconlyBold.discovery,
                  label: 'Nearby',
                  index: 1,
                  activeColor: Colors.black,
                ),
                _buildNavItem(
                  icon: Iconsax.heart,
                  label: 'Likes',
                  index: 2,
                  activeColor: const Color(0xFF00D9A3),
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
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              context.go('/encounters');
              break;
            case 1:
              // Nearby
              break;
            case 2:
              // Likes
              break;
            case 3:
              // Chats
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : Colors.grey[400],
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
