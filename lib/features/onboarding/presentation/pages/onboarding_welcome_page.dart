import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import '../widgets/welcome_match_indicator.dart';
import '../widgets/welcome_painters.dart';

class OnboardingWelcomePage extends ConsumerStatefulWidget {
  const OnboardingWelcomePage({super.key});

  @override
  ConsumerState<OnboardingWelcomePage> createState() =>
      _OnboardingWelcomePageState();
}

class _OnboardingWelcomePageState extends ConsumerState<OnboardingWelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _fadeController;
  late AnimationController _gridController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late AnimationController _matchAnimationController;
  late Animation<double> _matchScaleAnimation;
  late Animation<double> _matchProgressAnimation;

  @override
  void initState() {
    super.initState();
    _matchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _matchScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _matchAnimationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _matchProgressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _matchAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _matchAnimationController.forward();
      }
    });

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _gridController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _fadeController.dispose();
    _gridController.dispose();
    _glowController.dispose();
    _matchAnimationController.dispose();
    super.dispose();
  }

  int _calculateMatchPercentage() {
    // Calculate match percentage based on profile data
    return 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A14),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F1E),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced particles background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _particleController,
                  _glowController,
                ]),
                builder: (context, child) {
                  return CustomPaint(
                    painter: EnhancedParticlePainter(
                      animation: _particleController.value,
                      glowAnimation: _glowController.value,
                    ),
                  );
                },
              ),
            ),

            // Gradient overlay for depth
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),

                        // Enhanced Logo with animation
                        Align(
                          alignment: Alignment.topCenter,
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                width: 60.w,
                                height: 60.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.accentLight,
                                      Color(0xFFFF6B9D),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentLight.withValues(
                                        alpha:
                                            0.6 *
                                            (0.7 + _glowController.value * 0.3),
                                      ),
                                      blurRadius:
                                          30 + (_glowController.value * 10),
                                      spreadRadius:
                                          5 + (_glowController.value * 5),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFF6B9D).withValues(
                                        alpha:
                                            0.4 *
                                            (0.6 + _glowController.value * 0.4),
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: EdgeInsets.all(3.w),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/heartlink.png',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.favorite_rounded,
                                              size: 35.sp,
                                              color: AppColors.accentLight,
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Enhanced Profile Grid
                        _buildEnhancedProfileGrid(),

                        SizedBox(height: 30.h),

                        // App Logo with animated gradient
                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accentLight,
                                  const Color(0xFFFF6B9D),
                                  AppColors.accentLight.withValues(alpha: 0.9),
                                ],
                                stops: [
                                  0.0,
                                  0.5 + _glowController.value * 0.3,
                                  1.0,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                'HeartLink',
                                style: appStyle(
                                  52,
                                  Colors.white,
                                  FontWeight.w900,
                                ).copyWith(letterSpacing: -2.5, height: 1.0),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 10.h),

                        // Tagline with subtle animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                'Find Your Perfect Match',
                                style: appStyle(
                                  24,
                                  Colors.white,
                                  FontWeight.w700,
                                ).copyWith(letterSpacing: -0.5),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  'Join thousands discovering meaningful\nconnections every day',
                                  style: appStyle(
                                    13.sp,
                                    Colors.white.withValues(alpha: 0.65),
                                    FontWeight.w400,
                                  ).copyWith(height: 1.6),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Enhanced Get Started Button
                        _buildEnhancedButton(
                          text: 'Get Started',
                          onPressed: () => context.push('/register'),
                          isPrimary: true,
                        ),

                        SizedBox(height: 10.h),

                        // Sign up prompt with better styling
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: appStyle(
                                14,
                                Colors.white.withValues(alpha: 0.6),
                                FontWeight.w500,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/login'),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                child: Text(
                                  'Sign In',
                                  style: appStyle(
                                    14,
                                    AppColors.accentLight,
                                    FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedProfileGrid() {
    return AnimatedBuilder(
      animation: _gridController,
      builder: (context, child) {
        return SizedBox(
          height: 360.h,
          child: Stack(
            children: [
              // Multi-layer animated glow
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accentLight.withValues(
                              alpha: 0.2 * (0.4 + _glowController.value * 0.6),
                            ),
                            const Color(0xFFFF6B9D).withValues(
                              alpha: 0.15 * (0.3 + _glowController.value * 0.7),
                            ),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: ScreenUtil().screenHeight * 0.4,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Main big image (center)
                      Positioned(
                        left: 10.w,
                        top: 110.h,
                        child: _gridImage('assets/images/guy.jpeg'),
                      ),
                      Positioned(
                        top: 260.h,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: WelcomeMatchIndicator(
                            scaleAnimation: _matchScaleAnimation,
                            progressAnimation: _matchProgressAnimation,
                            matchPercentage: _calculateMatchPercentage(),
                          ),
                        ),
                      ),

                      // Top-right small image
                      Positioned(
                        right: 5.w,
                        top: 10.h,
                        child: _gridImage(
                          'assets/images/profile2.jpeg',

                          small: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _gridImage(String asset, {bool small = false}) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(25.r),
      child: Image.asset(
        asset,
        width: ScreenUtil().screenWidth * 0.45,
        height: ScreenUtil().screenHeight * 0.3,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildEnhancedButton({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: 58.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(29.r),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.accentLight.withValues(
                          alpha: 0.5 * (0.6 + _glowController.value * 0.4),
                        ),
                        blurRadius: 28,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withValues(
                          alpha: 0.3 * (0.5 + _glowController.value * 0.5),
                        ),
                        blurRadius: 20,
                        spreadRadius: -5,
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(29.r),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: isPrimary
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentLight,
                            const Color(0xFFFF6B9D),
                            AppColors.accentLight.withValues(alpha: 0.9),
                          ],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.15),
                            Colors.white.withValues(alpha: 0.08),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(29.r),
                  border: Border.all(
                    color: isPrimary
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    style: appStyle(
                      17,
                      Colors.white,
                      FontWeight.w700,
                    ).copyWith(letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
