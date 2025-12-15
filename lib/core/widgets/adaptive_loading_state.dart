import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

enum LoadingType { circular, linear, shimmer, skeleton, dots, pulse }

class AdaptiveLoadingState extends StatefulWidget {
  final LoadingType type;
  final String? message;
  final double? size;
  final Color? color;
  final Widget? child;
  final bool showMessage;
  final EdgeInsets? padding;

  const AdaptiveLoadingState({
    super.key,
    this.type = LoadingType.circular,
    this.message,
    this.size,
    this.color,
    this.child,
    this.showMessage = true,
    this.padding,
  });

  @override
  State<AdaptiveLoadingState> createState() => _AdaptiveLoadingStateState();
}

class _AdaptiveLoadingStateState extends State<AdaptiveLoadingState>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotsController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _dotsController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.type == LoadingType.pulse) {
      _pulseController.repeat(reverse: true);
    } else if (widget.type == LoadingType.dots) {
      _dotsController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loadingColor =
        widget.color ??
        (isDark ? AppColors.primaryDark : AppColors.primaryLight);

    final Widget loadingWidget = _buildLoadingWidget(loadingColor, isDark);

    return Padding(
      padding: widget.padding ?? EdgeInsets.all(16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          loadingWidget,
          if (widget.showMessage && widget.message != null) ...[
            SizedBox(height: 16.h),
            Text(
              widget.message!,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(Color color, bool isDark) {
    final size = widget.size ?? 40.w;

    switch (widget.type) {
      case LoadingType.circular:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3.w,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );

      case LoadingType.linear:
        return SizedBox(
          width: size * 3,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withValues(alpha: 0.2),
          ),
        );

      case LoadingType.shimmer:
        return widget.child ?? _buildDefaultShimmer(isDark);

      case LoadingType.skeleton:
        return _buildSkeleton(isDark);

      case LoadingType.dots:
        return _buildDotsLoader(color);

      case LoadingType.pulse:
        return AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.6),
                ),
              ),
            );
          },
        );
    }
  }

  Widget _buildDefaultShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: 200.w,
        height: 20.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }

  Widget _buildSkeleton(bool isDark) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 20.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            height: 20.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 150.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotsLoader(Color color) {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_dotsController.value - delay).clamp(
              0.0,
              1.0,
            );
            final scale =
                0.5 +
                (0.5 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0));

            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Specific loading states for common use cases
class ProfileLoadingState extends StatelessWidget {
  const ProfileLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveLoadingState(
      type: LoadingType.skeleton,
      message: 'Loading profile...',
    );
  }
}

class EncountersLoadingState extends StatelessWidget {
  const EncountersLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveLoadingState(
      type: LoadingType.pulse,
      message: 'Finding matches...',
    );
  }
}

class ChatLoadingState extends StatelessWidget {
  const ChatLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveLoadingState(
      type: LoadingType.dots,
      message: 'Loading conversations...',
    );
  }
}

class ImageUploadLoadingState extends StatelessWidget {
  final double progress;

  const ImageUploadLoadingState({super.key, this.progress = 0.0});

  @override
  Widget build(BuildContext context) {
    return AdaptiveLoadingState(
      type: LoadingType.linear,
      message: 'Uploading image... ${(progress * 100).toInt()}%',
    );
  }
}
