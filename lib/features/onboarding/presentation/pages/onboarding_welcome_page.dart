import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_button.dart';

class OnboardingWelcomePage extends ConsumerStatefulWidget {
  const OnboardingWelcomePage({super.key});

  @override
  ConsumerState<OnboardingWelcomePage> createState() =>
      _OnboardingWelcomePageState();
}

class _OnboardingWelcomePageState extends ConsumerState<OnboardingWelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.pink.shade50.withOpacity(0.3),
              Colors.purple.shade50.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Logo Container with floating effect
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 2),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                -10 * (0.5 - (value % 1.0 - 0.5).abs()),
                              ),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(28.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.pink.shade100.withOpacity(0.3),
                                  Colors.purple.shade100.withOpacity(0.2),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withOpacity(0.2),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.1),
                                  blurRadius: 60,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/dataDate.png',
                                height: 80.h,
                                width: 80.w,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 40.h),

                // Animated Welcome Text
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              Colors.pink.shade400,
                              Colors.purple.shade400,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'Welcome to DataDate! 🎉',
                            style: appStyle(
                              32,
                              Colors.white,
                              FontWeight.w900,
                            ).copyWith(letterSpacing: -0.5, height: 1.2),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            'Let\'s set up your profile to help you find the perfect match',
                            style: appStyle(
                              16,
                              Colors.grey[700]!,
                              FontWeight.w500,
                            ).copyWith(height: 1.6),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Feature highlights
                        _buildFeatureRow(),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Animated Buttons
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.5),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _controller,
                                curve: const Interval(
                                  0.4,
                                  1.0,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CustomButton(
                          text: 'Get Started',
                          onPressed: () {
                            context.push('/onboarding/gender-preference');
                          },
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Container(
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(42.r),
                      //     border: Border.all(
                      //       color: Colors.grey.shade200,
                      //       width: 1.5,
                      //     ),
                      //   ),
                      //   child: Material(
                      //     color: Colors.transparent,
                      //     child: InkWell(
                      //       onTap: () {
                      //         context.go('/encounters');
                      //       },
                      //       borderRadius: BorderRadius.circular(12.r),
                      //       child: Padding(
                      //         padding: EdgeInsets.symmetric(
                      //           vertical: 14.h,
                      //           horizontal: 24.w,
                      //         ),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Text(
                      //               'Skip for now',
                      //               style: appStyle(
                      //                 15,
                      //                 Colors.grey[600]!,
                      //                 FontWeight.w600,
                      //               ),
                      //             ),
                      //             SizedBox(width: 6.w),
                      //             Icon(
                      //               Icons.arrow_forward_ios_rounded,
                      //               size: 14,
                      //               color: Colors.grey[600],
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFeatureChip(Icons.verified_rounded, 'Verified'),
          SizedBox(width: 12.w),
          _buildFeatureChip(Icons.favorite_rounded, 'Safe'),
          SizedBox(width: 12.w),
          _buildFeatureChip(Icons.flash_on_rounded, 'Fast'),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink.shade50, Colors.purple.shade50],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.pink.shade100.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.pink.shade400, Colors.purple.shade400],
              ).createShader(bounds),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: appStyle(13, Colors.grey[700]!, FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
