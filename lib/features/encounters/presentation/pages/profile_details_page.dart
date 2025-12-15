import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:datadate/core/constants/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/custom_logs.dart';
import '../../../../core/utils/interest_emoji_mapper.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../domain/entities/profile.dart';
import '../providers/encounters_provider.dart';
import 'match_page.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

class ProfileDetailsPage extends ConsumerStatefulWidget {
  final Profile profile;

  const ProfileDetailsPage({super.key, required this.profile});

  @override
  ConsumerState<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends ConsumerState<ProfileDetailsPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;
  late AnimationController _matchAnimationController;
  late Animation<double> _matchScaleAnimation;
  late Animation<double> _matchProgressAnimation;
  bool _isLiking = false;

  void _nextImage() {
    CustomLogs.info(
      '_nextImage called - Current: $_currentPhotoIndex, Total: ${widget.profile.photos.length}',
    );
    if (_currentPhotoIndex < widget.profile.photos.length - 1) {
      setState(() {
        _currentPhotoIndex++;
        CustomLogs.info('Updated to: $_currentPhotoIndex');
      });
    } else {
      CustomLogs.info('Already at last image');
    }
  }

  void _previousImage() {
    CustomLogs.info('_previousImage called - Current: $_currentPhotoIndex');
    if (_currentPhotoIndex > 0) {
      setState(() {
        _currentPhotoIndex--;
        CustomLogs.info('Updated to: $_currentPhotoIndex');
      });
    } else {
      CustomLogs.info('Already at first image');
    }
  }

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
    // Use match score from API if available, otherwise default to 75
    return widget.profile.matchScore ?? 75;
  }

  Future<void> _handleLike() async {
    if (_isLiking) return;

    setState(() => _isLiking = true);
    HapticFeedback.mediumImpact();

    try {
      final matchInfo = await ref
          .read(encountersProvider.notifier)
          .likeProfile(widget.profile.id.toString());

      if (mounted) {
        // Check if it's a match
        if (matchInfo != null && matchInfo['matched'] == true) {
          // Extract room_id from match info
          final roomId = matchInfo['room_id'] as int?;

          if (roomId != null) {
            // Show match dialog
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MatchPage(
                      profileName: widget.profile.displayName,
                      profilePhoto: widget.profile.photos.first,
                      roomId: roomId,
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          }
        } else {
          // Just show success message and go back
          CustomSnackbar.show(
            context,
            message: 'Your like has been sent successfully!',
            type: SnackbarType.success,
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        // Parse error message
        String errorMessage = 'Failed to send like. Please try again.';
        if (e.toString().contains('already liked')) {
          errorMessage = 'You have already liked this profile.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        }

        CustomSnackbar.show(
          context,
          message: errorMessage,
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLiking = false);
      }
    }
  }

  Future<void> _handleSuperLike() async {
    if (_isLiking) return;

    setState(() => _isLiking = true);
    HapticFeedback.heavyImpact();

    try {
      final matchInfo = await ref
          .read(encountersProvider.notifier)
          .likeProfile(widget.profile.id.toString());

      if (mounted) {
        // Check if it's a match
        if (matchInfo != null && matchInfo['matched'] == true) {
          // Extract room_id from match info
          final roomId = matchInfo['room_id'] as int?;

          if (roomId != null) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    MatchPage(
                      profileName: widget.profile.displayName,
                      profilePhoto: widget.profile.photos.first,
                      roomId: roomId,
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            );
          }
        } else {
          CustomSnackbar.show(
            context,
            message: 'Super Like sent! They\'ll definitely notice you ⭐',
            type: SnackbarType.success,
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        // Parse error message
        String errorMessage = 'Failed to send super like. Please try again.';
        if (e.toString().contains('already liked')) {
          errorMessage = 'You have already liked this profile.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your connection.';
        }

        CustomSnackbar.show(
          context,
          message: errorMessage,
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLiking = false);
      }
    }
  }

  void _handleMessage() {
    HapticFeedback.lightImpact();
    CustomSnackbar.show(
      context,
      message: 'Messaging is only available after matching! 💬',
      type: SnackbarType.info,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.5;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Photo Gallery - Full width, starts from top with smooth transitions
          Positioned.fill(
            top: 0,
            bottom: screenHeight - imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: CachedNetworkImage(
                    key: ValueKey(_currentPhotoIndex),
                    imageUrl: widget.profile.photos[_currentPhotoIndex],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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
                ),

                // Minimal gradient overlay - only at top and bottom edges
                IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.3),
                        ],
                        stops: const [0.0, 0.15, 0.85, 1.0],
                      ),
                    ),
                  ),
                ),

                // Tap detector on top
                if (widget.profile.photos.length > 1)
                  Positioned.fill(
                    child: Row(
                      children: [
                        // Left half - previous
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              CustomLogs.info(
                                'Left tap detected - Current: $_currentPhotoIndex',
                              );
                              HapticFeedback.lightImpact();
                              _previousImage();
                              CustomLogs.info(
                                'After previous - New index: $_currentPhotoIndex',
                              );
                            },
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        // Right half - next
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              CustomLogs.info(
                                'Right tap detected - Current: $_currentPhotoIndex',
                              );
                              HapticFeedback.lightImpact();
                              _nextImage();
                              CustomLogs.info(
                                'After next - New index: $_currentPhotoIndex',
                              );
                            },
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
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
          if (widget.profile.photos.length > 1)
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(widget.profile.photos.length, (index) {
                  final isActive = index == _currentPhotoIndex;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 3,
                      margin: EdgeInsets.only(
                        right: index < widget.profile.photos.length - 1 ? 4 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Circular Match Percentage - positioned above the card
          Positioned(
            top: imageHeight - 120,
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
            top: imageHeight - 40,
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
                                                '${widget.profile.displayName}, ${widget.profile.age}',
                                                style: appStyle(
                                                  28,
                                                  Colors.black,
                                                  FontWeight.w900,
                                                ).copyWith(letterSpacing: -0.5),
                                              ),
                                            ),
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
                                                widget.profile.universityName,
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
                                        if (widget.profile.course != null) ...[
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.menu_book_rounded,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  widget.profile.course!,
                                                  style:
                                                      appStyle(
                                                        14,
                                                        Colors.grey[700]!,
                                                        FontWeight.w500,
                                                      ).copyWith(
                                                        letterSpacing: -0.2,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _handleMessage,
                                    child: Container(
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
                            // Shared Interests Section
                            if (widget.profile.sharedInterests.isNotEmpty)
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 750),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.favorite,
                                          color: Colors.pink,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'You Both Like',
                                          style: appStyle(
                                            18,
                                            Colors.black,
                                            FontWeight.w800,
                                          ).copyWith(letterSpacing: -0.4),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: widget.profile.sharedInterests
                                          .asMap()
                                          .entries
                                          .map(
                                            (entry) =>
                                                TweenAnimationBuilder<double>(
                                                  tween: Tween(
                                                    begin: 0.0,
                                                    end: 1.0,
                                                  ),
                                                  duration: Duration(
                                                    milliseconds:
                                                        750 + (entry.key * 100),
                                                  ),
                                                  curve: Curves.easeOutBack,
                                                  builder:
                                                      (context, value, child) {
                                                        return Transform.scale(
                                                          scale: value,
                                                          child: child,
                                                        );
                                                      },
                                                  child: _buildInterestChip(
                                                    entry.value,
                                                    isShared: true,
                                                  ),
                                                ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.profile.sharedInterests.isNotEmpty)
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
                            const SizedBox(height: 28),
                            // Additional Info Cards
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 850),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Opacity(opacity: value, child: child),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildInfoItem(
                                            'Age',
                                            widget.profile.age.toString(),
                                            Icons.cake_outlined,
                                          ),
                                        ),

                                        Expanded(
                                          child: _buildInfoItem(
                                            'Gender',
                                            widget.profile.gender.capitalize(),
                                            widget.profile.gender
                                                        .toLowerCase() ==
                                                    'male'
                                                ? Icons.male
                                                : Icons.female,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (widget.profile.course != null ||
                                        widget.profile.graduationYear !=
                                            null) ...[
                                      const SizedBox(height: 16),

                                      Row(
                                        children: [
                                          if (widget.profile.course != null)
                                            Expanded(
                                              child: _buildInfoItem(
                                                'Program',
                                                widget.profile.course!,
                                                Icons.school_outlined,
                                              ),
                                            ),
                                          if (widget.profile.course != null &&
                                              widget.profile.graduationYear !=
                                                  null)
                                            if (widget.profile.graduationYear !=
                                                null)
                                              Expanded(
                                                child: _buildInfoItem(
                                                  'Graduation',
                                                  widget.profile.graduationYear
                                                      .toString(),
                                                  Icons.calendar_today_outlined,
                                                ),
                                              ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
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
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 16),

                          // Center button (Like) - Larger
                          _buildActionButton(
                            icon: _isLiking
                                ? Icons.hourglass_empty
                                : Iconsax.heart,
                            color: AppColors.primaryLight,
                            size: 50,
                            onPressed: _isLiking ? null : _handleLike,
                          ),
                          const SizedBox(width: 16),

                          // Right button (Super Like)
                          _buildActionButton(
                            icon: Iconsax.star,
                            color: const Color(0xFFFFB800),
                            size: 50,
                            onPressed: _isLiking ? null : _handleSuperLike,
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

  Widget _buildInterestChip(String interest, {bool isShared = false}) {
    final emoji = InterestEmojiMapper.getEmoji(interest);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isShared ? Colors.pink[50] : Colors.white,
        borderRadius: BorderRadius.circular(44),
        border: Border.all(
          color: isShared ? Colors.pink[300]! : Colors.grey.shade300,
          width: isShared ? 1.5 : 0.7.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isShared
                ? Colors.pink.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Text(
            interest,
            style: appStyle(
              14,
              isShared ? Colors.pink[700]! : Colors.black87,
              FontWeight.w600,
            ).copyWith(letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.black87),
        const SizedBox(height: 8),
        Text(
          label,
          style: appStyle(
            12,
            Colors.grey[600]!,
            FontWeight.w500,
          ).copyWith(letterSpacing: -0.2),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: appStyle(
            15,
            Colors.black,
            FontWeight.w700,
          ).copyWith(letterSpacing: -0.3),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback? onPressed,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
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
            splashColor: color.withValues(alpha: 0.2),
            highlightColor: color.withValues(alpha: 0.1),
            child: AnimatedScale(
              scale: onPressed == null ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Center(
                  child: Icon(
                    icon,
                    color: onPressed == null
                        ? color.withValues(alpha: 0.5)
                        : color,
                    size: size * 0.45,
                  ),
                ),
              ),
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
