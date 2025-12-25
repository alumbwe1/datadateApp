import 'package:datadate/core/widgets/app_text_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_style.dart';
import '../providers/connectivity_provider.dart';
import '../services/connectivity_service.dart';
import 'connectivity_indicator.dart';

class ConnectivityAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool showConnectivityIndicator;
  final VoidCallback? onRefresh;

  const ConnectivityAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.showConnectivityIndicator = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final connectionAsync = ref.watch(connectionInfoProvider);

    return AppBar(
      title: Column(
        children: [
         const AppTextLogo(),
          if (showConnectivityIndicator)
            connectionAsync.when(
              data: (connection) =>
                  _buildConnectionStatus(context, connection, ref),
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
        ],
      ),
      leading: leading,
      actions: [
        if (showConnectivityIndicator)
          connectionAsync.when(
            data: (connection) =>
                _buildConnectivityAction(context, connection, ref),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
          ),
        ...?actions,
      ],
      centerTitle: centerTitle,
      backgroundColor:
          backgroundColor ??
          (isDarkMode ? const Color(0xFF1A1625) : Colors.white),
      foregroundColor: foregroundColor,
      elevation: elevation ?? 0,
      surfaceTintColor: Colors.transparent,
    );
  }

  Widget _buildConnectionStatus(
    BuildContext context,
    ConnectionInfo connection,
    WidgetRef ref,
  ) {
    // Only show status text for problematic connections
    if (connection.status == ConnectionStatus.excellent ||
        connection.status == ConnectionStatus.good) {
      return const SizedBox.shrink();
    }

    final statusText = _getStatusText(connection.status);
    final statusColor = _getStatusColor(connection.status);

    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Text(
        statusText,
        style: appStyle(11.sp, statusColor, FontWeight.w600),
      ),
    );
  }

  Widget _buildConnectivityAction(
    BuildContext context,
    ConnectionInfo connection,
    WidgetRef ref,
  ) {
    // Only show indicator for problematic connections
    if (connection.status == ConnectionStatus.excellent) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: () => _handleConnectivityTap(context, connection, ref),
        child: const ConnectivityIndicator(
          showInAppBar: true,
          showText: false,
          compact: true,
        ),
      ),
    );
  }

  void _handleConnectivityTap(
    BuildContext context,
    ConnectionInfo connection,
    WidgetRef ref,
  ) {
    if (connection.status == ConnectionStatus.none) {
      _showNoInternetDialog(context, ref);
    } else if (connection.isSlow) {
      _showSlowConnectionDialog(context, ref);
    }
  }

  void _showNoInternetDialog(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A1F35) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.signal_wifi_off, color: Colors.red, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'No Internet Connection',
              style: appStyle(
                16.sp,
                isDarkMode ? Colors.white : Colors.black,
                FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Please check your internet connection and try again.',
          style: appStyle(
            14.sp,
            isDarkMode ? Colors.white70 : Colors.black87,
            FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: appStyle(14.sp, Colors.grey, FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _refreshConnection(ref);
            },
            child: Text(
              'Retry',
              style: appStyle(14.sp, AppColors.secondaryLight, FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showSlowConnectionDialog(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A1F35) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.signal_wifi_bad, color: Colors.orange, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Slow Connection',
              style: appStyle(
                16.sp,
                isDarkMode ? Colors.white : Colors.black,
                FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your internet connection is slow. This may affect:',
              style: appStyle(
                14.sp,
                isDarkMode ? Colors.white70 : Colors.black87,
                FontWeight.w400,
              ),
            ),
            SizedBox(height: 8.h),
            _buildSlowConnectionEffect('• Message delivery', isDarkMode),
            _buildSlowConnectionEffect('• Image loading', isDarkMode),
            _buildSlowConnectionEffect('• Real-time updates', isDarkMode),
            SizedBox(height: 12.h),
            Text(
              'Consider switching to a better network or moving closer to your Wi-Fi router.',
              style: appStyle(
                13.sp,
                isDarkMode ? Colors.white60 : Colors.black54,
                FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: appStyle(14.sp, AppColors.secondaryLight, FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlowConnectionEffect(String text, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Text(
        text,
        style: appStyle(
          13.sp,
          isDarkMode ? Colors.white60 : Colors.black54,
          FontWeight.w400,
        ),
      ),
    );
  }

  void _refreshConnection(WidgetRef ref) {
    final service = ref.read(connectivityServiceProvider);
    service.refreshConnection();
    onRefresh?.call();
  }

  String _getStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.none:
        return 'No Internet';
      case ConnectionStatus.slow:
        return 'Slow Connection';
      case ConnectionStatus.good:
        return 'Good Connection';
      case ConnectionStatus.excellent:
        return 'Excellent';
    }
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.none:
        return Colors.red;
      case ConnectionStatus.slow:
        return Colors.orange;
      case ConnectionStatus.good:
        return Colors.blue;
      case ConnectionStatus.excellent:
        return Colors.green;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
