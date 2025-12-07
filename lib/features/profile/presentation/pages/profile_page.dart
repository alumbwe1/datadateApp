import 'package:cached_network_image/cached_network_image.dart';
import 'package:datadate/core/widgets/custom_snackbar.dart';
import 'package:datadate/core/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/constants/kolors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final isDarkMode = ref.watch(themeProvider.notifier).isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: bgColor,
        title: Text(
          'Profile',
          style: appStyle(
            24.sp,
            textColor,
            FontWeight.w700,
          ).copyWith(letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.setting_copy, color: textColor, size: 24),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showSettingsBottomSheet(context);
            },
          ),
        ],
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : profileState.error != null
          ? CustomErrorWidget(
              message: profileState.error!,
              onRetry: () {
                ref.read(profileProvider.notifier).loadProfile();
              },
            )
          : profile == null
          ? CustomErrorWidget(
              message: 'No profile data available',
              onRetry: () {
                ref.read(profileProvider.notifier).loadProfile();
              },
            )
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(profileProvider.notifier).loadProfile();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(context, profile),

                      const SizedBox(height: 32),
                      _buildInfoSection('About', profile),
                      const SizedBox(height: 24),
                      if (profile.interests.isNotEmpty)
                        _buildInterestsSection(profile),
                      if (profile.interests.isNotEmpty)
                        const SizedBox(height: 24),
                      _buildDetailsSection(profile),
                      const SizedBox(height: 32),
                      _buildActionButtons(context, ref),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  int _calculateProfileCompletion(dynamic profile) {
    int score = 0;
    if (profile.profilePhoto != null) score += 30;
    if (profile.bio != null && profile.bio!.isNotEmpty) score += 20;
    if (profile.displayName.isNotEmpty) score += 20;
    if (profile.age != null) score += 10;
    if (profile.course != null) score += 10;
    if (profile.interests.isNotEmpty) score += 10;
    return score;
  }

  Widget _buildProfileHeader(BuildContext context, dynamic profile) {
    final completionPercentage = _calculateProfileCompletion(profile);
    final progressColor = completionPercentage >= 80
        ? Colors.green
        : completionPercentage >= 50
        ? Colors.orange
        : Colors.red;

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Minimal circular progress
              SizedBox(
                width: 140,
                height: 140,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: completionPercentage / 100),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 4,
                      backgroundColor: Colors.grey[100],
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              // Profile photo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      profile.imageUrls != null && profile.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: profile.imageUrls[0],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[100],
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                        ),
                ),
              ),
              // Completion badge
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: progressColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$completionPercentage%',
                    style: appStyle(12, Colors.white, FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            profile.age != null
                ? '${profile.realName ?? profile.displayName}, ${profile.age}'
                : profile.realName ?? profile.displayName,
            style: appStyle(
              28,
              Colors.black,
              FontWeight.w700,
            ).copyWith(letterSpacing: -0.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  profile.universityData?['name'] as String? ?? 'University',
                  style: appStyle(13, Colors.grey[700]!, FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, dynamic profile) {
    final hasBio = profile.bio != null && profile.bio!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: appStyle(
            20,
            Colors.black,
            FontWeight.w700,
          ).copyWith(letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        Text(
          profile.bio ?? 'No bio yet. Tap edit to add one!',
          style: appStyle(
            14,
            hasBio ? Colors.grey[800]! : Colors.orange[900]!,
            FontWeight.w500,
          ).copyWith(height: 1.5),
        ),
      ],
    );
  }

  // Interest emoji mapping (same as edit_profile_page.dart)
  String _getInterestEmoji(String interest) {
    const interestEmojis = {
      'hiking': '🥾',
      'coffee': '☕',
      'coding': '💻',
      'AI': '🤖',
      'reading': '📚',
      'music': '🎵',
      'travel': '✈️',
      'fitness': '💪',
      'photography': '📸',
      'cooking': '🍳',
      'gaming': '🎮',
      'art': '🎨',
      'movies': '🎬',
      'sports': '⚽',
      'yoga': '🧘',
      'dancing': '💃',
      'nature': '🌿',
      'pets': '🐾',
      'fashion': '👗',
      'food': '🍕',
    };
    return interestEmojis[interest.toLowerCase()] ?? '✨';
  }

  Widget _buildInterestsSection(dynamic profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: appStyle(20.sp, Colors.black, FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profile.interests.map<Widget>((interest) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getInterestEmoji(interest),
                    style: appStyle(16.sp, Colors.black, FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    interest,
                    style: appStyle(
                      14.sp,
                      Colors.black,
                      FontWeight.w600,
                    ).copyWith(letterSpacing: -0.3),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(dynamic profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: appStyle(
            20,
            Colors.black,
            FontWeight.w700,
          ).copyWith(letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        if (profile.course != null && profile.course!.isNotEmpty)
          _buildDetailItem(
            icon: Icons.school_outlined,
            label: 'Course',
            value: profile.course!,
          ),
        if (profile.graduationYear != null)
          _buildDetailItem(
            icon: Iconsax.calendar_copy,
            label: 'Graduation Year',
            value: profile.graduationYear.toString(),
          ),
        if (profile.gender != null && profile.gender!.isNotEmpty)
          _buildDetailItem(
            icon: Iconsax.user_copy,
            label: 'Gender',
            value: profile.gender!.toUpperCase(),
          ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[700]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: appStyle(11, Colors.grey[600]!, FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: appStyle(15.sp, Colors.black, FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Edit Profile',
                  style: appStyle(16, Colors.white, FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showLogoutDialog(context, ref),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(color: Colors.red, width: 1.0.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.r),
              ),
              foregroundColor: Colors.red,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: appStyle(16, Colors.red, FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    final isDarkMode = ref.read(themeProvider.notifier).isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final handleColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];
    final textColor = isDarkMode ? Colors.white : Kolors.jetBlack;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                              color: Colors.black.withOpacity(0.05),
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
                'Account Settings',
                Iconsax.user_copy,
                () {
                  Navigator.pop(context);
                  _showAccountSettingsBottomSheet(context);
                },
              ),
              _buildBottomSheetOption('Privacy Policy', IconlyLight.lock, () {
                Navigator.pop(context);
                _launchUrl('https://your-privacy-policy-url.com');
              }),
              _buildBottomSheetOption(
                'Terms & Conditions',
                Iconsax.document_text_copy,
                () {
                  Navigator.pop(context);
                  _launchUrl('https://your-terms-url.com');
                },
              ),
              _buildBottomSheetOption(
                'Notifications',
                IconlyLight.notification,
                () => Navigator.pop(context),
              ),
              _buildBottomSheetOption(
                'Help & Support',
                Icons.help_outline,
                () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          CustomSnackbar.show(context, message: 'Could not open link');
        }
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(context, message: 'Error opening link');
      }
    }
  }

  void _showAccountSettingsBottomSheet(BuildContext context) {
    final isDarkMode = ref.read(themeProvider.notifier).isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                              color: Colors.black.withOpacity(0.05),
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
              _buildBottomSheetOption('Reset Password', Icons.lock_reset, () {
                Navigator.pop(context);
                _showResetPasswordDialog(context);
              }),
              _buildBottomSheetOption(
                'Delete Account',
                Icons.delete_forever_outlined,
                () {
                  Navigator.pop(context);
                  _showDeleteAccountDialog(context);
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
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
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock_reset, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Reset Password',
              style: appStyle(18, Colors.black, FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'A password reset link will be sent to your email address.',
          style: appStyle(14, Colors.black, FontWeight.w400),
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

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    bool isLoading = false;

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
                  style: appStyle(18, Colors.black, FontWeight.w800),
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
                style: appStyle(14, Colors.black, FontWeight.w400),
              ),
              const SizedBox(height: 20),
              Text(
                'Enter your password to confirm:',
                style: appStyle(13, Colors.grey[700]!, FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Current password',
                  hintStyle: appStyle(14, Colors.grey[400]!, FontWeight.w400),
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
                      child: LottieLoadingIndicator(),
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

  Widget _buildBottomSheetOption(
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
        ? Colors.red.withOpacity(0.1)
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
            ? Colors.red.withOpacity(0.5)
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.r),
        ),
        title: Text(
          'Logout',
          style: appStyle(18.sp, Colors.black, FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: appStyle(14, Colors.black, FontWeight.w400),
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
