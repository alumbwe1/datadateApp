import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_style.dart';

class CrushBottomSheet extends StatelessWidget {
  final String profileName;
  final String profilePhoto;

  const CrushBottomSheet({
    super.key,
    required this.profileName,
    required this.profilePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildProfileImage(),
                      const SizedBox(height: 32),
                      _buildTitle(),
                      const SizedBox(height: 20),
                      _buildDescription(),
                      const SizedBox(height: 32),
                      _buildSendButton(context),
                      const SizedBox(height: 24),
                      _buildCreditsInfo(),
                      const SizedBox(height: 20),
                      _buildMaybeLaterButton(context),
                      const SizedBox(height: 16),
                      _buildDisclaimer(),
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

  Widget _buildProfileImage() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.pink.withValues(alpha: 0.3),
                  Colors.red.withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundImage: CachedNetworkImageProvider(profilePhoto),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 45,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.rotate(
                    angle: (1 - value) * 0.5,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFFFE5196)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Iconsax.heart, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Send $profileName a Crush',
          style: appStyle(
            30,
            Colors.black,
            FontWeight.w900,
          ).copyWith(letterSpacing: -0.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pink.withValues(alpha: 0.15),
                Colors.purple.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Stand Out',
                style: appStyle(
                  12,
                  Colors.pink[700]!,
                  FontWeight.w700,
                ).copyWith(letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: appStyle(
            15,
            Colors.grey.shade700,
            FontWeight.w400,
          ).copyWith(height: 1.6, letterSpacing: -0.2),
          children: [
            const TextSpan(
              text:
                  'Don\'t just swipe right, stand out by sending a Crush and you\'re ',
            ),
            TextSpan(
              text: 'up to 2.2x more likely',
              style: appStyle(15, Colors.pink[600]!, FontWeight.w800),
            ),
            const TextSpan(text: ' to chat*'),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Iconsax.heart, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Crush sent to $profileName! 💕',
                      style: appStyle(14, Colors.white, FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.black,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.heart, size: 20),
            const SizedBox(width: 10),
            Text(
              'Send a Crush',
              style: appStyle(
                17,
                Colors.white,
                FontWeight.w700,
              ).copyWith(letterSpacing: -0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsInfo() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Out of Crushes',
                  style: appStyle(
                    15,
                    Colors.black,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: -0.3),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get another for 50 credits',
                  style: appStyle(
                    13,
                    Colors.grey[700]!,
                    FontWeight.w500,
                  ).copyWith(letterSpacing: -0.2),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildMaybeLaterButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        'Maybe later',
        style: appStyle(
          16,
          Colors.grey.shade600,
          FontWeight.w600,
        ).copyWith(letterSpacing: -0.3),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Text(
      '*Based on top 10% of 2.7m users sample',
      style: appStyle(
        11,
        Colors.grey.shade400,
        FontWeight.w600,
      ).copyWith(letterSpacing: -0.2),
      textAlign: TextAlign.center,
    );
  }
}
