import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

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

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _ageRange;

  @override
  void initState() {
    super.initState();
    _ageRange = RangeValues(widget.initialMinAge, widget.initialMaxAge);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            SizedBox(height: 20.h),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryLight.withOpacity(0.15),
                          AppColors.primaryLight.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.primaryLight,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Filter Preferences',
                    style: appStyle(
                      22,
                      Colors.black,
                      FontWeight.w800,
                    ).copyWith(letterSpacing: -0.5),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _ageRange = const RangeValues(18, 35);
                      });
                    },
                    child: Text(
                      'Reset',
                      style: appStyle(
                        14,
                        AppColors.primaryLight,
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Age Range Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Age Range',
                        style: appStyle(16, Colors.black87, FontWeight.w600),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryLight.withOpacity(0.1),
                              AppColors.secondaryLight.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '${_ageRange.start.round()} - ${_ageRange.end.round()} years',
                          style: appStyle(
                            14,
                            AppColors.primaryLight,
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Range Slider
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 4.h,
                      activeTrackColor: AppColors.primaryLight,
                      inactiveTrackColor: Colors.grey[200],
                      thumbColor: Colors.white,
                      overlayColor: AppColors.primaryLight.withOpacity(0.2),
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 12.r,
                        elevation: 4,
                      ),
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: 24.r,
                      ),
                      rangeThumbShape: RoundRangeSliderThumbShape(
                        enabledThumbRadius: 12.r,
                        elevation: 4,
                      ),
                      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                      valueIndicatorColor: AppColors.primaryLight,
                      valueIndicatorTextStyle: appStyle(
                        12,
                        Colors.white,
                        FontWeight.w600,
                      ),
                    ),
                    child: RangeSlider(
                      values: _ageRange,
                      min: 18,
                      max: 60,
                      divisions: 42,
                      labels: RangeLabels(
                        _ageRange.start.round().toString(),
                        _ageRange.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _ageRange = values;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Min and Max Labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '18',
                        style: appStyle(12, Colors.grey[600]!, FontWeight.w500),
                      ),
                      Text(
                        '60',
                        style: appStyle(12, Colors.grey[600]!, FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Apply Button
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply Filters',
                    style: appStyle(16, Colors.white, FontWeight.w700),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
