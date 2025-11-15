import 'package:datadate/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600;
    final isSmallScreen = screenHeight < 700;

    final List<Map<String, String>> profiles = [
      {
        'image':
            'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=400',
        'name': 'Marcus',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400',
        'name': 'Amara',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
        'name': 'David',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
        'name': 'Zara',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'name': 'Chris',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        'name': 'Maya',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            //AppLogo
            Positioned(
              top: isSmallScreen ? 10 : 20,
              left: screenWidth / 2 - (isTablet ? 20 : 17.5),
              child: Image.asset(
                'assets/images/dataDate.png',
                height: isTablet ? 40 : 35,
                width: isTablet ? 40 : 35,
                fit: BoxFit.cover,
              ),
            ),
            // Top section with angled grid
            Positioned(
              top: isSmallScreen ? 60 : 80,
              left: 0,
              right: 0,
              height: screenHeight * (isSmallScreen ? 0.45 : 0.5),
              child: Stack(
                children: [
                  // Angled container with grid
                  Positioned.fill(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 40 : 24,
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: isSmallScreen ? 0.85 : 1,
                          crossAxisSpacing: isTablet ? 16 : 5,
                          mainAxisSpacing: isTablet ? 16 : 5,
                        ),
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              // Image
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    isTablet ? 30 : 25,
                                  ),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      profiles[index]['image']!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Name overlay at bottom
                              Positioned(
                                left: isTablet ? 16 : 12,
                                bottom: isTablet ? 8 : 5,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      profiles[index]['name']!,
                                      style: appStyle(
                                        isTablet ? 13 : 11,
                                        Colors.white,
                                        FontWeight.w600,
                                      ).copyWith(letterSpacing: -0.3),
                                    ),
                                    SizedBox(width: isTablet ? 6 : 4),
                                    Icon(
                                      Icons.verified,
                                      color: const Color(0xFFFFD700),
                                      size: isTablet ? 18 : 15,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.6),
                            Colors.black,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom content section
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 48 : 32,
                    0,
                    isTablet ? 48 : 32,
                    isSmallScreen ? 20 : 40,
                  ),
                  child: Column(
                    children: [
                      _StarIcon(isTablet: isTablet),
                      SizedBox(height: isSmallScreen ? 10 : 15),

                      // Headline
                      Text(
                        'Meet Campus Elite\n& Find Your Match',
                        style: appStyle(
                          isTablet ? 40 : (isSmallScreen ? 28 : 32),
                          Colors.white,
                          FontWeight.w900,
                        ).copyWith(letterSpacing: -0.3, height: 1.1),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isSmallScreen ? 8 : 12),

                      // Subheading
                      Text(
                        'Connect with verified students. Where the\nrich & ambitious come to date 💎',
                        style: appStyle(
                          isTablet ? 16.sp : 15.sp,
                          Colors.grey[400]!,
                          FontWeight.w400,
                        ).copyWith(height: 1.5),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isSmallScreen ? 24 : 40),

                      // Sign up button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/register'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 20 : 18,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Create Account',
                            style: appStyle(
                              isTablet ? 18 : 16,
                              Colors.black,
                              FontWeight.w700,
                            ).copyWith(letterSpacing: 0.3),
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Log in button
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Already have an account? Sign In',
                          style: appStyle(
                            isTablet ? 15.sp : 14.sp,
                            Colors.grey[400]!,
                            FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Terms text
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 24 : 16,
                        ),
                        child: Text(
                          'By signing up, you are creating a DataDate account and agree to DataDate\'s Terms and Privacy Policy',
                          style: appStyle(
                            isTablet ? 12 : 11,
                            Colors.white38,
                            FontWeight.w400,
                          ).copyWith(height: 1.3),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarIcon extends StatelessWidget {
  final bool isTablet;

  const _StarIcon({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Transform.rotate(
            angle: (1 - value) * 3.14,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 10,
                  vertical: isTablet ? 5 : 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 16),
                  color: AppColors.mellowLime,
                ),
                child: SvgPicture.asset(
                  'assets/svgs/star3.svg',
                  width: isTablet ? 70.r : 35.r,
                  height: isTablet ? 70.r : 35.r,
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    Colors.blue,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
