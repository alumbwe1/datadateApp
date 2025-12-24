import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_style.dart';
import '../providers/connectivity_provider.dart';
import '../services/connectivity_service.dart';

class ConnectivityStatusBanner extends ConsumerWidget {
  final bool showOnlyWhenPoor;
  final EdgeInsets? margin;

  const ConnectivityStatusBanner({
    super.key,
    this.showOnlyWhenPoor = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(connectionInfoProvider);

    return connectionAsync.when(
      data: (connection) => _buildBanner(context, connection, ref),
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildBanner(
    BuildContext context,
    ConnectionInfo connection,
    WidgetRef ref,
  ) {
    // Only show banner for poor connections if showOnlyWhenPoor is true
    if (showOnlyWhenPoor &&
        (connection.status == ConnectionStatus.excellent ||
            connection.status == ConnectionStatus.good)) {
      return const SizedBox.shrink();
    }

    final color = _getConnectionColor(connection.status);
    final icon = _getConnectionIcon(connection.status, connection.type);
    final text = _getConnectionText(connection);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: color),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(text, style: appStyle(12.sp, color, FontWeight.w600)),
          ),
          if (connection.status == ConnectionStatus.none) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => _refreshConnection(ref),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'Retry',
                  style: appStyle(10.sp, Colors.white, FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getConnectionColor(ConnectionStatus status) {
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

  IconData _getConnectionIcon(ConnectionStatus status, ConnectionType type) {
    if (status == ConnectionStatus.none) {
      return Icons.signal_wifi_off;
    }

    switch (type) {
      case ConnectionType.wifi:
        return status == ConnectionStatus.slow
            ? Icons.signal_wifi_bad
            : Icons.wifi;
      case ConnectionType.mobile:
        return status == ConnectionStatus.slow
            ? Icons.signal_cellular_connected_no_internet_0_bar
            : Icons.signal_cellular_alt;
      case ConnectionType.ethernet:
        return Icons.settings_ethernet;
      case ConnectionType.vpn:
        return Icons.vpn_lock;
      case ConnectionType.bluetooth:
        return Icons.bluetooth;
      default:
        return status == ConnectionStatus.slow
            ? Icons.signal_wifi_bad
            : Icons.signal_wifi_4_bar;
    }
  }

  String _getConnectionText(ConnectionInfo connection) {
    switch (connection.status) {
      case ConnectionStatus.none:
        return 'No internet connection. Check your network settings.';
      case ConnectionStatus.slow:
        return 'Slow connection detected. Messages may be delayed.';
      case ConnectionStatus.good:
        return 'Good connection';
      case ConnectionStatus.excellent:
        return 'Excellent connection';
    }
  }

  void _refreshConnection(WidgetRef ref) {
    final service = ref.read(connectivityServiceProvider);
    service.refreshConnection();
  }
}
