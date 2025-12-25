import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_style.dart';
import '../providers/connectivity_provider.dart';
import '../services/connectivity_service.dart';

class NetworkErrorBoundary extends ConsumerWidget {
  final Widget child;
  final String? fallbackMessage;
  final VoidCallback? onRetry;

  const NetworkErrorBoundary({
    super.key,
    required this.child,
    this.fallbackMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(connectionInfoProvider);

    return connectionAsync.when(
      data: (connection) {
        // If we have a good connection, show the child
        if (connection.isConnected) {
          return child;
        }

        // If offline, show offline state
        return _buildOfflineState(context, connection);
      },
      loading: () => child, // Show child while loading connection status
      error: (error, stack) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildOfflineState(BuildContext context, ConnectionInfo connection) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.signal_wifi_off, size: 80.w, color: Colors.orange),
              SizedBox(height: 24.h),
              Text(
                'No Internet Connection',
                style: appStyle(
                  24.sp,
                  isDarkMode ? Colors.white : Colors.black,
                  FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                fallbackMessage ??
                    'You\'re currently offline. The app will work with cached data and sync when you\'re back online.',
                style: appStyle(
                  16.sp,
                  isDarkMode ? Colors.grey[300]! : Colors.grey[600]!,
                  FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              _buildOfflineFeatures(isDarkMode),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed:
                    onRetry ??
                    () {
                      // Try to refresh connection
                      final service = ConnectivityService();
                      service.refreshConnection();
                    },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Try Again',
                      style: appStyle(16.sp, Colors.white, FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineFeatures(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Available Offline:',
            style: appStyle(
              14.sp,
              isDarkMode ? Colors.white : Colors.black,
              FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          _buildOfflineFeature(
            'View cached messages',
            Icons.chat_bubble_outline,
          ),
          _buildOfflineFeature('Browse saved profiles', Icons.person_outline),
          _buildOfflineFeature('Queue new messages', Icons.schedule),
          _buildOfflineFeature('View match history', Icons.favorite_outline),
        ],
      ),
    );
  }

  Widget _buildOfflineFeature(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Colors.orange),
          SizedBox(width: 8.w),
          Text(text, style: appStyle(13.sp, Colors.orange, FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80.w, color: Colors.red),
              SizedBox(height: 24.h),
              Text(
                'Connection Error',
                style: appStyle(
                  24.sp,
                  isDarkMode ? Colors.white : Colors.black,
                  FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'There was a problem connecting to our servers. Please check your internet connection and try again.',
                style: appStyle(
                  16.sp,
                  isDarkMode ? Colors.grey[300]! : Colors.grey[600]!,
                  FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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
                  'Retry Connection',
                  style: appStyle(16.sp, Colors.white, FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
