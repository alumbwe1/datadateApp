import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../features/encounters/presentation/pages/encounters_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const EncountersPage(),
    const Center(child: Text('Nearby - Coming Soon')),
    const Center(child: Text('Likes - Coming Soon')),
    const Center(child: Text('Chats - Coming Soon')),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
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
