import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_style.dart';
import '../../domain/entities/profile.dart';
import '../pages/profile_details_page.dart';

class ProfileCard extends StatelessWidget {
  final Profile profile;

  const ProfileCard({super.key, required this.profile});

  void _showCrushBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile image with animated heart
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow ring
                            Container(
                              width: 136,
                              height: 136,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.pink.withOpacity(0.3),
                                    Colors.red.withOpacity(0.2),
                                  ],
                                ),
                              ),
                            ),
                            // Profile image
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 58,
                                backgroundImage: CachedNetworkImageProvider(
                                  profile.photos.first,
                                ),
                              ),
                            ),
                            // Heart badge
                            Positioned(
                              bottom: 0,
                              right: 45,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.pink, Colors.red],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.pink.withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Iconsax.heart,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Title
                      Text(
                        'Send ${profile.name} a Crush',
                        style: appStyle(
                          28,

                          Colors.black,
                          FontWeight.bold,
                        ).copyWith(letterSpacing: -0.3),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Description with highlight
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: appStyle(
                              15,
                              Colors.grey.shade700,
                              FontWeight.normal,
                            ).copyWith(height: 1.5, letterSpacing: -0.3),
                            children: [
                              const TextSpan(
                                text:
                                    'Don\'t just swipe right, stand out by sending a Crush and you\'re ',
                              ),
                              TextSpan(
                                text: 'up to 2.2x more likely',
                                style: appStyle(
                                  15,
                                  Colors.pink[600]!,
                                  FontWeight.bold,
                                ),
                              ),
                              const TextSpan(text: ' to chat*'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Primary button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text('Crush sent to ${profile.name}!'),
                                  ],
                                ),
                                backgroundColor: Colors.black,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shadowColor: Colors.black.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Send a Crush',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Credits info card
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 0.7,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.yellowAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.stars_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Out of Crushes',
                                    style: appStyle(
                                      15,
                                      Colors.black,
                                      FontWeight.w600,
                                    ).copyWith(letterSpacing: -0.3),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Get another for 50 credits',
                                    style: appStyle(
                                      13,
                                      Colors.grey[600]!,
                                      FontWeight.normal,
                                    ).copyWith(letterSpacing: -0.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Secondary button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Text(
                          'Maybe later',
                          style: appStyle(
                            16,
                            Colors.grey.shade600,
                            FontWeight.w500,
                          ).copyWith(letterSpacing: -0.3),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Disclaimer
                      Text(
                        '*Based on top 10% of 2.7m users sample',
                        style: appStyle(
                          11,
                          Colors.grey.shade400,
                          FontWeight.bold,
                        ).copyWith(letterSpacing: -0.3),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileDetailsPage(profile: profile),
          ),
        );
      },
      onDoubleTap: () {
        _showCrushBottomSheet(context);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Profile Image
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: profile.photos.first,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.grey[300]),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[300]!, Colors.grey[200]!],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 120,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),

              // Gradient overlay at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 280,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Profile Info - NOW AT TOP
              Positioned(
                left: 20,
                right: 70,
                top: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${profile.name}, ${profile.age}',
                            style: appStyle(28, Colors.white, FontWeight.w800)
                                .copyWith(
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isOnline)
                          Container(
                            width: 14,
                            height: 14,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FF94),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF00FF94,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Relationship goal badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Iconsax.heart,
                            color: Colors.black,
                            size: 16,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Here for ${profile.relationshipGoal}',
                            style: appStyle(
                              13,
                              Colors.black,
                              FontWeight.w600,
                            ).copyWith(letterSpacing: -0.2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Location badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            profile.location,
                            style: appStyle(
                              13,
                              Colors.white,
                              FontWeight.w600,
                            ).copyWith(letterSpacing: -0.2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // More button
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
