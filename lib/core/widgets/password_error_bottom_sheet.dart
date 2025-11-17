import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_style.dart';

class PasswordErrorBottomSheet extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const PasswordErrorBottomSheet({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  static void show(
    BuildContext context, {
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PasswordErrorBottomSheet(
        errorMessage: errorMessage,
        onRetry: onRetry,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          SizedBox(height: 24.h),

          // Error icon
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_outline, size: 48, color: Colors.red[400]),
          ),

          SizedBox(height: 20.h),

          // Title
          Text(
            'Password Issue',
            style: appStyle(
              24,
              Colors.black,
              FontWeight.w900,
            ).copyWith(letterSpacing: -0.5),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12.h),

          // Error message
          Text(
            errorMessage,
            style: appStyle(
              15,
              Colors.grey[700]!,
              FontWeight.w500,
            ).copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 24.h),

          // Password requirements
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Requirements:',
                  style: appStyle(14, Colors.black, FontWeight.w700),
                ),
                SizedBox(height: 12.h),
                _buildRequirement('At least 8 characters long'),
                _buildRequirement('Not similar to your email or username'),
                _buildRequirement('Not too common (e.g., "password123")'),
                _buildRequirement('Not entirely numeric'),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Try Again',
                style: appStyle(16, Colors.white, FontWeight.w700),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: appStyle(13, Colors.grey[700]!, FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
