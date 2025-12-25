import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_style.dart';

class CachedDataIndicator extends StatelessWidget {
  final bool isVisible;
  final String? customMessage;
  final VoidCallback? onRefresh;

  const CachedDataIndicator({
    super.key,
    required this.isVisible,
    this.customMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: isDarkMode
          ? Colors.amber.shade900.withValues(alpha: 0.3)
          : Colors.amber.shade100,
      child: Row(
        children: [
          Icon(
            Icons.offline_bolt_outlined,
            size: 16.sp,
            color: isDarkMode ? Colors.amber.shade300 : Colors.amber.shade700,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              customMessage ?? 'Showing cached data • Pull to refresh',
              style: appStyle(
                12.sp,
                isDarkMode ? Colors.amber.shade300 : Colors.amber.shade700,
                FontWeight.w500,
              ),
            ),
          ),
          if (onRefresh != null) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onRefresh,
              child: Icon(
                Icons.refresh,
                size: 16.sp,
                color: isDarkMode
                    ? Colors.amber.shade300
                    : Colors.amber.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
