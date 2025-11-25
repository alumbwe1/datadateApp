import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

class BoostBottomSheet extends ConsumerStatefulWidget {
  const BoostBottomSheet({super.key});

  @override
  ConsumerState<BoostBottomSheet> createState() => _BoostBottomSheetState();
}

class _BoostBottomSheetState extends ConsumerState<BoostBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _selectedDuration = 2; // hours
  double _amount = 10.0;

  final List<Map<String, dynamic>> _boostPackages = [
    {'duration': 1, 'views': 50, 'amount': 5.0, 'popular': false},
    {'duration': 2, 'views': 100, 'amount': 10.0, 'popular': true},
    {'duration': 4, 'views': 200, 'amount': 18.0, 'popular': false},
    {'duration': 8, 'views': 500, 'amount': 35.0, 'popular': false},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Load boost pricing
    // TODO: Implement boost provider
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(boostProvider.notifier).loadBoostPricing();
    // });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement boost provider
    // final boostState = ref.watch(boostProvider);
    final isLoading = false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              SizedBox(height: 24.h),

              // Animated Boost Icon
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentLight,
                            AppColors.accentLight.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentLight.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        size: 40.sp,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 20.h),

              // Title
              Text(
                'Boost Your Profile',
                style: appStyle(
                  28,
                  Colors.black,
                  FontWeight.w900,
                ).copyWith(letterSpacing: -0.8),
              ),

              SizedBox(height: 8.h),

              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'Get 10x more profile views and increase your chances of matching',
                  style: appStyle(
                    15,
                    Colors.grey[600]!,
                    FontWeight.w500,
                  ).copyWith(height: 1.4, letterSpacing: -0.2),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 32.h),

              // Boost Packages
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: _boostPackages.map((package) {
                    final isSelected = package['duration'] == _selectedDuration;
                    final isPopular = package['popular'] as bool;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedDuration = package['duration'] as int;
                          _amount = package['amount'] as double;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.accentLight.withValues(
                                      alpha: 0.15,
                                    ),
                                    AppColors.accentLight.withValues(
                                      alpha: 0.08,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : Colors.grey[50],
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentLight
                                : Colors.grey[200]!,
                            width: isSelected ? 2.w : 1.w,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.accentLight.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                // Icon
                                Container(
                                  width: 50.w,
                                  height: 50.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isSelected
                                          ? [
                                              AppColors.accentLight,
                                              AppColors.accentLight.withValues(
                                                alpha: 0.8,
                                              ),
                                            ]
                                          : [
                                              Colors.grey[300]!,
                                              Colors.grey[200]!,
                                            ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Icon(
                                    Icons.bolt_rounded,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[600],
                                    size: 26.sp,
                                  ),
                                ),

                                SizedBox(width: 16.w),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${package['duration']} Hour${package['duration'] > 1 ? 's' : ''}',
                                            style: appStyle(
                                              17,
                                              Colors.black,
                                              FontWeight.w800,
                                            ).copyWith(letterSpacing: -0.3),
                                          ),
                                          if (isPopular) ...[
                                            SizedBox(width: 8.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8.w,
                                                vertical: 4.h,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    AppColors.accentLight,
                                                    AppColors.accentLight
                                                        .withValues(alpha: 0.8),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Text(
                                                'POPULAR',
                                                style: appStyle(
                                                  9,
                                                  Colors.white,
                                                  FontWeight.w900,
                                                ).copyWith(letterSpacing: 0.5),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        '~${package['views']} profile views',
                                        style: appStyle(
                                          13,
                                          Colors.grey[600]!,
                                          FontWeight.w500,
                                        ).copyWith(letterSpacing: -0.2),
                                      ),
                                    ],
                                  ),
                                ),

                                // Price
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'K${package['amount'].toStringAsFixed(0)}',
                                      style: appStyle(
                                        20,
                                        isSelected
                                            ? AppColors.accentLight
                                            : Colors.black,
                                        FontWeight.w900,
                                      ).copyWith(letterSpacing: -0.5),
                                    ),
                                    Text(
                                      'ZMW',
                                      style: appStyle(
                                        11,
                                        Colors.grey[600]!,
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Selection indicator
                            if (isSelected)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 24.h),

              // Benefits
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What you get:',
                      style: appStyle(
                        16,
                        Colors.black,
                        FontWeight.w800,
                      ).copyWith(letterSpacing: -0.3),
                    ),
                    SizedBox(height: 16.h),
                    _buildBenefitItem(
                      Icons.visibility_rounded,
                      '10x more profile views',
                      Colors.blue,
                    ),
                    SizedBox(height: 12.h),
                    _buildBenefitItem(
                      Icons.star_rounded,
                      'Priority in discovery',
                      Colors.amber,
                    ),
                    SizedBox(height: 12.h),
                    _buildBenefitItem(
                      Icons.favorite_rounded,
                      'More likes & matches',
                      Colors.red,
                    ),
                    SizedBox(height: 12.h),
                    _buildBenefitItem(
                      Icons.trending_up_rounded,
                      'Real-time progress tracking',
                      Colors.green,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Boost Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _handleBoost();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentLight,
                            AppColors.accentLight.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentLight.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Boost for K${_amount.toStringAsFixed(0)}',
                              style: appStyle(
                                17,
                                Colors.white,
                                FontWeight.w800,
                              ).copyWith(letterSpacing: -0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Terms
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  'Your profile will be shown first in discovery for $_selectedDuration hour${_selectedDuration > 1 ? 's' : ''}',
                  style: appStyle(
                    12,
                    Colors.grey[500]!,
                    FontWeight.w500,
                  ).copyWith(height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: color, size: 18.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: appStyle(
              14,
              Colors.grey[800]!,
              FontWeight.w600,
            ).copyWith(letterSpacing: -0.2),
          ),
        ),
      ],
    );
  }

  void _handleBoost() async {
    // TODO: Implement boost API call
    // For now, show a demo message
    if (mounted) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentLight,
                      AppColors.accentLight.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bolt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Boost Feature',
                      style: appStyle(14, Colors.white, FontWeight.w700),
                    ),
                    Text(
                      'Coming soon! K${_amount.toStringAsFixed(0)} for $_selectedDuration hour${_selectedDuration > 1 ? 's' : ''}',
                      style: appStyle(12, Colors.white70, FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }
}
