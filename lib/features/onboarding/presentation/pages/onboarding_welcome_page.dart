import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_style.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> profiles = [
      {
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        'name': 'Chris',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
        'name': 'Matt',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        'name': 'John',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
        'name': 'Sylvia',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400',
        'name': 'Jay',
      },
      {
        'image':
            'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
        'name': 'Sarah',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Top section with angled grid
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55,
            child: Stack(
              children: [
                // Angled container with grid
                Positioned.fill(
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0008)
                      ..rotateX(-0.3),
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              // Image
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      profiles[index]['image']!,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Name overlay at top
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        profiles[index]['name']!,
                                        style: appStyle(
                                          11,
                                          Colors.white,
                                          FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFD700),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.black,
                                          size: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.6),
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
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Column(
                  children: [
                    // Star icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Headline
                    Text(
                      'Date Zambia\'s Elite',
                      style: appStyle(
                        32,
                        Colors.white,
                        FontWeight.w900,
                      ).copyWith(letterSpacing: -0.5, height: 1.1),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subheading
                    Text(
                      'Connect with verified rich singles and\nfind your perfect match',
                      style: appStyle(
                        14,
                        Colors.white60,
                        FontWeight.w400,
                      ).copyWith(height: 1.4),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Sign up button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Create Account',
                          style: appStyle(
                            16,
                            Colors.black,
                            FontWeight.w700,
                          ).copyWith(letterSpacing: 0.3),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Log in button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text(
                          'Sign In',
                          style: appStyle(
                            16,
                            Colors.white,
                            FontWeight.w600,
                          ).copyWith(letterSpacing: 0.3),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Terms text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'By signing up, you are creating a DataDate account and agree to DataDate\'s Terms and Privacy Policy',
                        style: appStyle(
                          11,
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
    );
  }
}
