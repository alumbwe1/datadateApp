import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../domain/entities/profile.dart';
import 'dart:math' as math;

class ProfileDetailsPage extends StatefulWidget {
  final Profile profile;

  const ProfileDetailsPage({super.key, required this.profile});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
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

          // Back button
          Positioned(
            top: 50,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Circular Match Percentage in Center
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: MediaQuery.of(context).size.width / 2 - 60,
            child: _buildCircularMatchIndicator(),
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
                            Row(
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
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.school,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            widget.profile.location
                                                .toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Iconsax.message),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ).copyWith(letterSpacing: -0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Love to travel, explore new places, and meet interesting people. Looking for someone to share adventures with! 🌍✨',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Interest',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ).copyWith(letterSpacing: -0.2),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: widget.profile.interests
                                  .map(
                                    (interest) => _buildInterestChip(interest),
                                  )
                                  .toList(),
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

                  // Action buttons - Fixed layout
                  Container(
                    margin: const EdgeInsets.only(bottom: 40),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
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
      width: MediaQuery.of(context).size.width * 0.35,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress indicator
              SizedBox(
                width: 45,
                height: 45,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    progress: matchPercentage / 100,
                    strokeWidth: 5,
                    color: Colors.deepPurpleAccent,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
              // Percentage text
              Text(
                '$matchPercentage%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(width: 5),
          Text(
            'Match',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ).copyWith(letterSpacing: -0.3),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    IconData icon;
    switch (interest.toLowerCase()) {
      case 'gaming':
        icon = Icons.sports_esports;
        break;
      case 'music':
        icon = Icons.music_note;
        break;
      case 'book':
      case 'reading':
        icon = Icons.book;
        break;
      case 'photography':
        icon = Icons.camera_alt;
        break;
      default:
        icon = Icons.favorite;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            interest,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
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
