import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_style.dart';
import '../../../../core/providers/theme_provider.dart';
import 'account_deletion_feedback_sheet.dart';
import 'profile_dialogs.dart';

class ProfileAccountSettingsBottomSheet extends ConsumerWidget {
  const ProfileAccountSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.read(themeProvider.notifier).isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Account Settings',
                    style: appStyle(
                      20.sp,
                      textColor,
                      FontWeight.w800,
                    ).copyWith(letterSpacing: -0.3),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.close, size: 20.w, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildBottomSheetOption(
              context,
              ref,
              'Reset Password',
              Icons.lock_reset,
              () {
                Navigator.pop(context);
                ProfileDialogs.showResetPasswordDialog(context, ref);
              },
            ),
            _buildBottomSheetOption(
              context,
              ref,
              'Delete Account',
              Icons.delete_forever_outlined,
              () {
                 Navigator.pop(context);
               _showDeleteAccountFeedbackSheet(context);
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  
  void _showDeleteAccountFeedbackSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AccountDeletionFeedbackSheet(),
    );
  }

  Widget _buildBottomSheetOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final isDarkMode = ref.read(themeProvider.notifier).isDarkMode;
    final color = isDestructive
        ? Colors.red
        : isDarkMode
        ? Colors.white
        : Colors.grey[700]!;
    final bgColor = isDestructive
        ? Colors.red.withValues(alpha: 0.1)
        : isDarkMode
        ? Colors.grey[800]!
        : Colors.grey[100]!;
    final textColor = isDestructive
        ? Colors.red
        : isDarkMode
        ? Colors.white
        : Colors.black;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: appStyle(15.sp, textColor, FontWeight.w600)),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive
            ? Colors.red.withValues(alpha: 0.5)
            : isDarkMode
            ? Colors.grey[600]
            : Colors.grey[400],
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}
