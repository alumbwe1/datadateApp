import 'package:datadate/core/widgets/close_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/constants/kolors.dart';

class FilterBottomSheet extends StatefulWidget {
  final double initialMinAge;
  final double initialMaxAge;
  final Function(double minAge, double maxAge) onApply;

  const FilterBottomSheet({
    super.key,
    this.initialMinAge = 18,
    this.initialMaxAge = 35,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late RangeValues _ageRange;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _ageRange = RangeValues(widget.initialMinAge, widget.initialMaxAge);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleReset() {
    setState(() {
      _ageRange = const RangeValues(18, 35);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32.r),
              topRight: Radius.circular(32.r),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minimal Drag Handle
                Container(
                  margin: EdgeInsets.only(top: 8.h, bottom: 4.h),
                  width: 36.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),

                SizedBox(height: 20.h),

                // Clean Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    spacing: 5.h,
                    children: [
                      Text(
                        'Filters',
                        style: appStyle(
                          28.sp,
                          Colors.black,
                          FontWeight.w700,
                        ).copyWith(letterSpacing: -0.3),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: _handleReset,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22.r),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 2), // subtle iOS shadow
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.refresh,
                            size: 20.w,
                            color: Kolors.jetBlack,
                          ),
                        ),
                      ),

                      CloseIcon(),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),

                // Age Range Card
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Label
                        Text(
                          'Age Range',
                          style: appStyle(
                            17,
                            Colors.black.withOpacity(0.6),
                            FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Large Age Display
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Row(
                            key: ValueKey(
                              '${_ageRange.start}-${_ageRange.end}',
                            ),
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${_ageRange.start.round()}',
                                style: appStyle(
                                  48,
                                  Colors.black,
                                  FontWeight.w700,
                                ).copyWith(letterSpacing: -0.3.sp, height: 1.0),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: Text(
                                  '—',
                                  style: appStyle(
                                    32.sp,
                                    Colors.black.withOpacity(0.3),
                                    FontWeight.w400,
                                  ),
                                ),
                              ),
                              Text(
                                '${_ageRange.end.round()}',
                                style: appStyle(
                                  48.sp,
                                  Colors.black,
                                  FontWeight.w700,
                                ).copyWith(letterSpacing: -0.3.sp, height: 1.0),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'years',
                                style: appStyle(
                                  17,
                                  Colors.black.withOpacity(0.4),
                                  FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // Minimalist Range Slider
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 4.h,
                            activeTrackColor: Colors.black,
                            inactiveTrackColor: Colors.black.withOpacity(0.08),
                            thumbColor: Colors.black,
                            overlayColor: Colors.black.withOpacity(0.08),
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 10.r,
                              elevation: 0,
                            ),
                            overlayShape: RoundSliderOverlayShape(
                              overlayRadius: 20.r,
                            ),
                            rangeThumbShape: RoundRangeSliderThumbShape(
                              enabledThumbRadius: 10.r,
                              elevation: 0,
                            ),
                            rangeTrackShape:
                                const RoundedRectRangeSliderTrackShape(),
                            valueIndicatorShape:
                                const PaddleSliderValueIndicatorShape(),
                            valueIndicatorColor: Colors.black,
                            valueIndicatorTextStyle: appStyle(
                              14,
                              Colors.white,
                              FontWeight.w600,
                            ),
                            showValueIndicator:
                                ShowValueIndicator.onlyForDiscrete,
                          ),
                          child: RangeSlider(
                            values: _ageRange,
                            min: 18,
                            max: 60,
                            divisions: 42,
                            labels: RangeLabels(
                              '${_ageRange.start.round()}',
                              '${_ageRange.end.round()}',
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _ageRange = values;
                              });
                            },
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Subtle Range Labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '18',
                              style: appStyle(
                                13,
                                Colors.black.withOpacity(0.4),
                                FontWeight.w500,
                              ),
                            ),
                            Text(
                              '60',
                              style: appStyle(
                                13,
                                Colors.black.withOpacity(0.4),
                                FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Clean Apply Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_ageRange.start, _ageRange.end);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Apply',
                        style: appStyle(
                          17,
                          Colors.white,
                          FontWeight.w600,
                        ).copyWith(letterSpacing: -0.3),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
