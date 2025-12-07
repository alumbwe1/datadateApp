import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

class LikesEmptyState extends StatefulWidget {
  final bool isReceived;

  const LikesEmptyState({super.key, required this.isReceived});

  @override
  State<LikesEmptyState> createState() => _LikesEmptyStateState();
}

class _LikesEmptyStateState extends State<LikesEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 5.h,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Lottie.asset(
                    'assets/lottie/lovempty.json',
                    width: 140.h,
                    height: 140.h,
                    fit: BoxFit.contain,
                  ),
                ),

                Text(
                  widget.isReceived ? 'No Likes Yet' : 'No Likes Sent',
                  style: appStyle(
                    28.sp,
                    Colors.black,
                    FontWeight.w800,
                  ).copyWith(letterSpacing: -0.5),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5.h),
                Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.secondaryLight.withOpacity(0.6),
                        AppColors.secondaryLight.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.isReceived
                        ? 'When someone likes you, they\'ll appear here.'
                        : 'Start swiping right on profiles you like.\nYour likes will appear here.',
                    style: appStyle(
                      16.sp,
                      Colors.grey[600]!,
                      FontWeight.w400,
                    ).copyWith(height: 1.5, letterSpacing: -0.2),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
