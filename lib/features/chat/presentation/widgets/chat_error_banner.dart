import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../providers/chat_detail_provider.dart';

class ChatErrorBanner extends ConsumerWidget {
  final int roomId;

  const ChatErrorBanner({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatDetailProvider(roomId));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (chatState.error == null) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _getErrorColor(chatState.error!).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _getErrorColor(chatState.error!).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(chatState.error!),
            size: 20.sp,
            color: _getErrorColor(chatState.error!),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getErrorTitle(chatState.error!),
                  style: appStyle(
                    13.sp,
                    _getErrorColor(chatState.error!),
                    FontWeight.w600,
                  ),
                ),
                if (_getErrorDescription(chatState.error!) != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    _getErrorDescription(chatState.error!)!,
                    style: appStyle(
                      11.sp,
                      isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                      FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_shouldShowRetryButton(chatState.error!)) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () => _handleRetry(context, ref, chatState.error!),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getErrorColor(chatState.error!),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  _getRetryButtonText(chatState.error!),
                  style: appStyle(11.sp, Colors.white, FontWeight.w600),
                ),
              ),
            ),
          ],
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _dismissError(ref),
            child: Icon(
              Icons.close,
              size: 18.sp,
              color: _getErrorColor(chatState.error!),
            ),
          ),
        ],
      ),
    );
  }

  Color _getErrorColor(String error) {
    if (error.contains('queued') || error.contains('offline')) {
      return Colors.orange;
    } else if (error.contains('timeout') || error.contains('connection')) {
      return Colors.amber;
    } else if (error.contains('failed') || error.contains('error')) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  IconData _getErrorIcon(String error) {
    if (error.contains('queued') || error.contains('offline')) {
      return Icons.schedule;
    } else if (error.contains('timeout')) {
      return Icons.access_time;
    } else if (error.contains('connection')) {
      return Icons.signal_wifi_bad;
    } else if (error.contains('failed')) {
      return Icons.error_outline;
    } else {
      return Icons.info_outline;
    }
  }

  String _getErrorTitle(String error) {
    if (error.contains('queued')) {
      return 'Message Queued';
    } else if (error.contains('timeout')) {
      return 'Connection Timeout';
    } else if (error.contains('offline')) {
      return 'Offline Mode';
    } else if (error.contains('failed')) {
      return 'Action Failed';
    } else {
      return 'Notice';
    }
  }

  String? _getErrorDescription(String error) {
    if (error.contains('queued')) {
      return 'Will be sent when connection is restored';
    } else if (error.contains('timeout')) {
      return 'Please check your internet connection';
    } else if (error.contains('offline')) {
      return 'Messages will be queued until you\'re back online';
    } else if (error.contains('session expired') || error.contains('401')) {
      return 'Please log in again';
    }
    return null;
  }

  bool _shouldShowRetryButton(String error) {
    return error.contains('failed') ||
        error.contains('timeout') ||
        (error.contains('queued') && !error.contains('will be sent'));
  }

  String _getRetryButtonText(String error) {
    if (error.contains('queued')) {
      return 'Retry Now';
    } else if (error.contains('timeout')) {
      return 'Retry';
    } else {
      return 'Try Again';
    }
  }

  void _handleRetry(BuildContext context, WidgetRef ref, String error) {
    final notifier = ref.read(chatDetailProvider(roomId).notifier);

    if (error.contains('queued')) {
      notifier.retryQueuedMessages();
    } else if (error.contains('timeout') || error.contains('failed')) {
      // Retry loading messages
      notifier.loadMessages();
    }

    // Show feedback
    CustomSnackbar.show(
      context,
      message: 'Retrying...',
      type: SnackbarType.info,
      duration: const Duration(seconds: 1),
    );

    _dismissError(ref);
  }

  void _dismissError(WidgetRef ref) {
    // Clear the error using the clearError method
    ref.read(chatDetailProvider(roomId).notifier).clearError();
  }
}
