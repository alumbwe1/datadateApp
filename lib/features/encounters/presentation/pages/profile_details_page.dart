import 'package:cached_network_image/cached_network_image.dart';
import 'package:datadate/core/constants/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../domain/entities/profile.dart';
import 'dart:math' as math;

class ProfileDetailsPage extends StatefulWidget {
  final Profile profile;

  const ProfileDetailsPage({super.key, required this.profile});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _matchAnimationController.dispose();
    super.dispose();
  }

  int _calculateMatchPercentage() {
    // Calculate match percentage based on profile data
    return 85 + (widget.profile.interests.length * 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Photo Gallery with looping
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPhotoIndex = index % widget.profile.photos.length;
                });
              },
              itemCount: widget.profile.photos.length * 1000,
              itemBuilder: (context, index) {
                final photoIndex = index % widget.profile.photos.length;
                return GestureDetector(
                  onTapUp: (details) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    if (details.globalPosition.dx > screenWidth / 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: CachedNetworkImage(
                    imageUrl: widget.profile.photos[photoIndex],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.person, size: 100),
                    ),
                  ),
                );
              },
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
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Back button with animation
          Positioned(
            top: 50,
            left: 16,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 22,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),

          // Photo indicators
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: widget.profile.photos.length > 1
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Row(
                      children: List.generate(
                        widget.profile.photos.length,
                        (index) => Expanded(
                          child: Container(
                            height: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: _currentPhotoIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Circular Match Percentage in Center
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _matchScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _matchScaleAnimation.value,
                    child: child,
                  );
                },
                child: _buildCircularMatchIndicator(),
              ),
            ),
          ),

          // Scrollable Profile info card
          Positioned(
            left: 0,
            top: MediaQuery.of(context).size.height * 0.45,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '${widget.profile.name}, ${widget.profile.age}',
                                                style: appStyle(
                                                  28,
                                                  Colors.black,
                                                  FontWeight.w900,
                                                ).copyWith(letterSpacing: -0.5),
                                              ),
                                            ),
                                            if (widget.profile.isOnline) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF4CAF50,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFF4CAF50,
                                                      ).withValues(alpha: 0.5),
                                                      blurRadius: 8,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.school_outlined,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                widget.profile.university,
                                                style: appStyle(
                                                  14,
                                                  Colors.grey[700]!,
                                                  FontWeight.w600,
                                                ).copyWith(letterSpacing: -0.2),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              IconlyLight.location,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              widget.profile.location,
                                              style: appStyle(
                                                14,
                                                Colors.grey[700]!,
                                                FontWeight.w500,
                                              ).copyWith(letterSpacing: -0.2),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF000000),
                                          Color(0xFF2a2a2a),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Iconsax.message,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'About Me',
                                    style: appStyle(
                                      18,
                                      Colors.black,
                                      FontWeight.w800,
                                    ).copyWith(letterSpacing: -0.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    widget.profile.bio ??
                                        'Love to travel, explore new places, and meet interesting people. Looking for someone to share adventures with! 🌍✨',
                                    style:
                                        appStyle(
                                          15,
                                          Colors.grey[800]!,
                                          FontWeight.w400,
                                        ).copyWith(
                                          height: 1.5,
                                          letterSpacing: -0.2,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Interests',
                                    style: appStyle(
                                      18,
                                      Colors.black,
                                      FontWeight.w800,
                                    ).copyWith(letterSpacing: -0.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: widget.profile.interests
                                        .asMap()
                                        .entries
                                        .map(
                                          (
                                            entry,
                                          ) => TweenAnimationBuilder<double>(
                                            tween: Tween(begin: 0.0, end: 1.0),
                                            duration: Duration(
                                              milliseconds:
                                                  800 + (entry.key * 100),
                                            ),
                                            curve: Curves.easeOutBack,
                                            builder: (context, value, child) {
                                              return Transform.scale(
                                                scale: value,
                                                child: child,
                                              );
                                            },
                                            child: _buildInterestChip(
                                              entry.value,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    'Age',
                                    widget.profile.age.toString(),
                                  ),
                                ),
                                Expanded(
                                  child: _buildInfoItem(
                                    'University',
                                    widget.profile.university,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Action buttons - Fixed layout with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 40),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF000000), Color(0xFF2a2a2a)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left button (Nope)
                          _buildActionButton(
                            icon: Icons.close,
                            color: Colors.black,
                            size: 50,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 16),

                          // Center button (Like) - Larger
                          _buildActionButton(
                            icon: Iconsax.heart,
                            color: Colors.black,
                            size: 50,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 16),

                          // Right button (Super Like)
                          _buildActionButton(
                            icon: Iconsax.star,
                            color: const Color(0xFFFFB800),
                            size: 50,
                            onPressed: () {
                              // Super like action
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularMatchIndicator() {
    final matchPercentage = _calculateMatchPercentage();

    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Animated circular progress indicator
              AnimatedBuilder(
                animation: _matchProgressAnimation,
                builder: (context, child) {
                  return SizedBox(
                    width: 50,
                    height: 50,
                    child: CustomPaint(
                      painter: CircularProgressPainter(
                        progress:
                            (matchPercentage / 100) *
                            _matchProgressAnimation.value,
                        strokeWidth: 5,
                        color: Colors.deepPurpleAccent,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  );
                },
              ),
              // Animated percentage text
              AnimatedBuilder(
                animation: _matchProgressAnimation,
                builder: (context, child) {
                  final displayPercentage =
                      (matchPercentage * _matchProgressAnimation.value).toInt();
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Text(
                          '$displayPercentage%',
                          style: appStyle(
                            16,
                            Colors.black,
                            FontWeight.w900,
                          ).copyWith(letterSpacing: -0.5),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Match',
                style: appStyle(
                  17,
                  Colors.black,
                  FontWeight.w800,
                ).copyWith(letterSpacing: -0.4, height: 1),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurpleAccent.withValues(alpha: 0.2),
                      Colors.pinkAccent.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Great!',
                  style: appStyle(
                    10,
                    Colors.deepPurple,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    IconData icon;
    Color iconColor;

    switch (interest.toLowerCase()) {
      case 'gaming':
        icon = Icons.sports_esports;
        iconColor = Colors.purple;
        break;
      case 'music':
        icon = Icons.music_note;
        iconColor = Colors.pink;
        break;
      case 'book':
      case 'reading':
        icon = Icons.book;
        iconColor = Colors.blue;
        break;
      case 'photography':
        icon = Icons.camera_alt;
        iconColor = Colors.orange;
        break;
      case 'travel':
        icon = Icons.flight;
        iconColor = Colors.teal;
        break;
      case 'fitness':
        icon = Icons.fitness_center;
        iconColor = Colors.red;
        break;
      case 'cooking':
        icon = Icons.restaurant;
        iconColor = Colors.deepOrange;
        break;
      case 'art':
        icon = Icons.palette;
        iconColor = Colors.indigo;
        break;
      default:
        icon = Icons.favorite;
        iconColor = Colors.pink;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: Colors.grey.shade300, width: 0.7.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Text(
            interest,
            style: appStyle(
              14,
              Colors.black87,
              FontWeight.w600,
            ).copyWith(letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: appStyle(12, Colors.grey[600]!, FontWeight.normal)),
        const SizedBox(height: 4),
        Text(value, style: appStyle(16, Colors.black, FontWeight.w600)),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Center(
              child: Icon(icon, color: color, size: size * 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
