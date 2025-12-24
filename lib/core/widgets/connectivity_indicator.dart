import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_colors.dart';
import '../constants/app_style.dart';
import '../providers/connectivity_provider.dart';
import '../services/connectivity_service.dart';

class ConnectivityIndicator extends ConsumerWidget {
  final bool showInAppBar;
  final bool showText;
  final bool compact;

  const ConnectivityIndicator({
    super.key,
    this.showInAppBar = true,
    this.showText = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(connectionInfoProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return connectionAsync.when(
      data: (connection) => _buildIndicator(context, connection, isDarkMode),
      loading: () => _buildLoadingIndicator(isDarkMode),
      error: (error, stack) => _buildErrorIndicator(isDarkMode),
    );
  }

  Widget _buildIndicator(
    BuildContext context,
    ConnectionInfo connection,
    bool isDarkMode,
  ) {
    // Don't show anything for excellent connection to avoid clutter
    if (connection.status == ConnectionStatus.excellent && showInAppBar) {
      return const SizedBox.shrink();
    }

    final color = _getConnectionColor(connection.status);
    final icon = _getConnectionIcon(connection.status, connection.type);
    final text = _getConnectionText(connection);

    if (compact) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12.sp, color: color),
            if (showText) ...[
              SizedBox(width: 4.w),
              Text(
                _getShortText(connection.status),
                style: appStyle(10.sp, color, FontWeight.w600),
              ),
            ],
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showConnectionDetails(context, connection),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: showInAppBar ? 8.w : 12.w,
          vertical: showInAppBar ? 4.h : 8.h,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(showInAppBar ? 12.r : 16.r),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: showInAppBar ? 14.sp : 16.sp, color: color),
            if (showText) ...[
              SizedBox(width: 6.w),
              Text(
                text,
                style: appStyle(
                  showInAppBar ? 11.sp : 13.sp,
                  color,
                  FontWeight.w600,
                ),
              ),
            ],
            if (connection.status != ConnectionStatus.none) ...[
              SizedBox(width: 4.w),
              _buildSignalStrengthIndicator(connection, color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignalStrengthIndicator(ConnectionInfo connection, Color color) {
    final strength = _getSignalStrength(connection);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          width: 2.w,
          height: (4 + (index * 2)).h,
          margin: EdgeInsets.only(left: index > 0 ? 1.w : 0),
          decoration: BoxDecoration(
            color: index < strength ? color : color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(1.r),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingIndicator(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: SizedBox(
        width: 12.w,
        height: 12.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIndicator(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Icon(
        Icons.error_outline,
        size: 14.sp,
        color: isDarkMode ? Colors.white70 : Colors.black54,
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
        return Icons.wifi;
      case ConnectionType.mobile:
        return Icons.signal_cellular_alt;
      case ConnectionType.ethernet:
        return Icons.settings_ethernet;
      case ConnectionType.vpn:
        return Icons.vpn_lock;
      case ConnectionType.bluetooth:
        return Icons.bluetooth;
      default:
        return Icons.signal_wifi_4_bar;
    }
  }

  String _getConnectionText(ConnectionInfo connection) {
    if (connection.status == ConnectionStatus.none) {
      return 'No Internet';
    }

    final typeText = _getConnectionTypeText(connection.type);
    final statusText = _getConnectionStatusText(connection.status);

    return '$statusText $typeText';
  }

  String _getShortText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.none:
        return 'Offline';
      case ConnectionStatus.slow:
        return 'Slow';
      case ConnectionStatus.good:
        return 'Good';
      case ConnectionStatus.excellent:
        return 'Fast';
    }
  }

  String _getConnectionTypeText(ConnectionType type) {
    switch (type) {
      case ConnectionType.wifi:
        return 'Wi-Fi';
      case ConnectionType.mobile:
        return 'Mobile';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.vpn:
        return 'VPN';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      default:
        return 'Network';
    }
  }

  String _getConnectionStatusText(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.none:
        return 'No';
      case ConnectionStatus.slow:
        return 'Slow';
      case ConnectionStatus.good:
        return 'Good';
      case ConnectionStatus.excellent:
        return 'Fast';
    }
  }

  int _getSignalStrength(ConnectionInfo connection) {
    switch (connection.status) {
      case ConnectionStatus.none:
        return 0;
      case ConnectionStatus.slow:
        return 1;
      case ConnectionStatus.good:
        return 2;
      case ConnectionStatus.excellent:
        return 3;
    }
  }

  void _showConnectionDetails(BuildContext context, ConnectionInfo connection) {
    showDialog(
      context: context,
      builder: (context) => ConnectionDetailsDialog(connection: connection),
    );
  }
}

class ConnectionDetailsDialog extends StatelessWidget {
  final ConnectionInfo connection;

  const ConnectionDetailsDialog({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDarkMode ? const Color(0xFF2A1F35) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Row(
        children: [
          Icon(
            Icons.network_check,
            color: AppColors.secondaryLight,
            size: 24.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            'Connection Details',
            style: appStyle(
              18.sp,
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
          _buildDetailRow(
            'Status',
            _getStatusText(connection.status),
            _getStatusColor(connection.status),
            isDarkMode,
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            'Type',
            _getTypeText(connection.type),
            isDarkMode ? Colors.white70 : Colors.black87,
            isDarkMode,
          ),
          if (connection.latency > 0) ...[
            SizedBox(height: 12.h),
            _buildDetailRow(
              'Latency',
              '${connection.latency}ms',
              _getLatencyColor(connection.latency),
              isDarkMode,
            ),
          ],
          if (connection.speed != null) ...[
            SizedBox(height: 12.h),
            _buildDetailRow(
              'Speed',
              '~${connection.speed}Mbps',
              _getSpeedColor(connection.speed!),
              isDarkMode,
            ),
          ],
          SizedBox(height: 12.h),
          _buildDetailRow(
            'Stability',
            connection.isStable ? 'Stable' : 'Unstable',
            connection.isStable ? Colors.green : Colors.orange,
            isDarkMode,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: appStyle(14.sp, AppColors.secondaryLight, FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color valueColor,
    bool isDarkMode,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: appStyle(
            14.sp,
            isDarkMode ? Colors.white70 : Colors.black54,
            FontWeight.w500,
          ),
        ),
        Text(value, style: appStyle(14.sp, valueColor, FontWeight.w600)),
      ],
    );
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
        return 'Excellent Connection';
    }
  }

  String _getTypeText(ConnectionType type) {
    switch (type) {
      case ConnectionType.none:
        return 'No Connection';
      case ConnectionType.mobile:
        return 'Mobile Data';
      case ConnectionType.wifi:
        return 'Wi-Fi';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.vpn:
        return 'VPN';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.other:
        return 'Other';
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

  Color _getLatencyColor(int latency) {
    if (latency < 50) return Colors.green;
    if (latency < 100) return Colors.blue;
    if (latency < 300) return Colors.orange;
    return Colors.red;
  }

  Color _getSpeedColor(int speed) {
    if (speed >= 25) return Colors.green;
    if (speed >= 10) return Colors.blue;
    if (speed >= 5) return Colors.orange;
    return Colors.red;
  }
}
