import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_style.dart';
import '../../../../core/constants/kolors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'profile_account_settings_bottom_sheet.dart';

class ProfileSettingsBottomSheet extends ConsumerWidget {
  const ProfileSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.read(themeProvider.notifier).isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Kolors.jetBlack;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
                    'Settings',
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
            const SizedBox(height: 20),
            _buildBottomSheetOption(
              context,
              ref,
              'Account Settings',
              Iconsax.user_copy,
              () {
                Navigator.pop(context);
                _showAccountSettingsBottomSheet(context, ref);
              },
            ),
            _buildBottomSheetOption(
              context,
              ref,
              'Privacy Policy',
              IconlyLight.lock,
              () {
                Navigator.pop(context);
                _launchUrl(context, 'https://your-privacy-policy-url.com');
              },
            ),
            _buildBottomSheetOption(
              context,
              ref,
              'Terms & Conditions',
              Iconsax.document_text_copy,
              () {
                Navigator.pop(context);
                _launchUrl(context, 'https://your-terms-url.com');
              },
            ),
            _buildBottomSheetOption(
              context,
              ref,
              'Notifications',
              IconlyLight.notification,
              () => Navigator.pop(context),
            ),
            _buildThemeToggleOption(ref),
            _buildBottomSheetOption(
              context,
              ref,
              'Help & Support',
              Icons.help_outline,
              () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleOption(WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    final bgColor = isDarkMode ? Colors.grey[800]! : Colors.grey[100]!;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.white : Colors.grey[700]!;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text('Theme', style: appStyle(15.sp, textColor, FontWeight.w600)),
      subtitle: Text(
        isDarkMode ? 'Dark Mode' : 'Light Mode',
        style: appStyle(
          13.sp,
          textColor.withValues(alpha: 0.7),
          FontWeight.w400,
        ),
      ),
      trailing: Switch.adaptive(
        value: isDarkMode,
        onChanged: (_) {
          HapticFeedback.lightImpact();
          ref.read(themeProvider.notifier).toggleTheme();
        },
        activeThumbColor: const Color(0xFFFF6B9D),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(themeProvider.notifier).toggleTheme();
      },
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

  void _showAccountSettingsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfileAccountSettingsBottomSheet(),
    );
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          CustomSnackbar.show(context, message: 'Could not open link');
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(context, message: 'Error opening link');
      }
    }
  }
}
