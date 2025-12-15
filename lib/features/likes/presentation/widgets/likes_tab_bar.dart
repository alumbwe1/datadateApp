import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

class LikesTabBar extends StatelessWidget {
  final TabController controller;

  const LikesTabBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ModernTabBarDelegate(
        TabBar(
          controller: controller,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          labelStyle: appStyle(15, Colors.white, FontWeight.w700),
          unselectedLabelStyle: appStyle(
            15,
            Colors.grey[600]!,
            FontWeight.w600,
          ),
          indicator: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondaryLight,
                AppColors.secondaryLight.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryLight.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
    );
  }
}

class _ModernTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _ModernTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_ModernTabBarDelegate oldDelegate) {
    return false;
  }
}
