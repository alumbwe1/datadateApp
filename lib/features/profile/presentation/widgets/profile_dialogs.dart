import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_style.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileDialogs {
  static void showResetPasswordDialog(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.read(themeProvider.notifier).isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_reset, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Reset Password',
              style: appStyle(18, textColor, FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'A password reset link will be sent to your email address.',
          style: appStyle(14, textColor, FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: appStyle(14.sp, Colors.grey.shade600, FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement password reset
              Navigator.pop(context);
              CustomSnackbar.show(
                context,
                message: 'Password reset link sent to your email',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Text(
              'Send Link',
              style: appStyle(14.sp, Colors.white, FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static void showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    bool isLoading = false;
    final isDarkMode = ref.read(themeProvider.notifier).isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_rounded, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Account',
                  style: appStyle(18, textColor, FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
                style: appStyle(14, textColor, FontWeight.w400),
              ),
              const SizedBox(height: 20),
              Text(
                'Enter your password to confirm:',
                style: appStyle(
                  13,
                  isDarkMode ? Colors.grey[400]! : Colors.grey[700]!,
                  FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Current password',
                  hintStyle: appStyle(
                    14,
                    isDarkMode ? Colors.grey[500]! : Colors.grey[400]!,
                    FontWeight.w400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: appStyle(14.sp, Colors.grey, FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (passwordController.text.trim().isEmpty) {
                        CustomSnackbar.show(
                          context,
                          message: 'Please enter your password',
                          type: SnackbarType.error,
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      final success = await ref
                          .read(authProvider.notifier)
                          .deleteAccount(passwordController.text.trim());

                      if (context.mounted) {
                        if (success) {
                          Navigator.pop(context);
                          context.go('/login');
                          CustomSnackbar.show(
                            context,
                            message: 'Your account has been deleted',
                            type: SnackbarType.success,
                          );
                        } else {
                          setState(() => isLoading = false);
                          final error = ref.read(authProvider).error;
                          CustomSnackbar.show(
                            context,
                            message: error ?? 'Failed to delete account',
                            type: SnackbarType.error,
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const LottieLoadingIndicator(),
                    )
                  : Text(
                      'Delete',
                      style: appStyle(14.sp, Colors.white, FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static void showLogoutDialog(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.read(themeProvider.notifier).isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.r),
        ),
        title: Text(
          'Logout',
          style: appStyle(18.sp, textColor, FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: appStyle(14, textColor, FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: appStyle(14.sp, Colors.grey.shade600, FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            child: Text(
              'Logout',
              style: appStyle(14.sp, Colors.red, FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
