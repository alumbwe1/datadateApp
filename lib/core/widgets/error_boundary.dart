import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../utils/custom_logs.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallback;
  final void Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.fallback,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();

    // Override the global error handler for this widget tree
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          _errorDetails = details;
        });
      }

      // Log the error
      CustomLogs.error(
        'Error Boundary caught: ${details.exception}',
        tag: 'ERROR_BOUNDARY',
        error: details.exception,
        stackTrace: details.stack,
      );

      // Call custom error handler if provided
      widget.onError?.call(details);

      // Send to Crashlytics in production
      if (kReleaseMode) {
        // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return widget.fallback ?? _buildErrorWidget(context);
    }

    return widget.child;
  }

  Widget _buildErrorWidget(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80.w, color: AppColors.error),
              SizedBox(height: 24.h),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'We\'re sorry for the inconvenience. The app encountered an unexpected error.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              if (kDebugMode) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Debug Info:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _errorDetails?.exception.toString() ?? 'Unknown error',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'monospace',
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorDetails = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
