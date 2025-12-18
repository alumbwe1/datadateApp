import 'package:cached_network_image/cached_network_image.dart';
import 'package:datadate/core/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/widgets/error_widget.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_dialogs.dart';
import '../widgets/profile_settings_bottom_sheet.dart';
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
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => const ProfileSettingsBottomSheet(),
              );
            },
          ),
        ],
      ),
      body: profileState.isLoading
          ? const Center(child: LottieLoadingIndicator())
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
                      _buildProfileHeader(context, profile, isDarkMode),

                      const SizedBox(height: 32),
                      _buildInfoSection('About', profile),
                      const SizedBox(height: 24),
                      if (profile.interests.isNotEmpty)
                        _buildInterestsSection(profile, isDarkMode),
                      if (profile.interests.isNotEmpty)
                        const SizedBox(height: 24),
                      _buildDetailsSection(profile, isDarkMode),
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

  Widget _buildProfileHeader(
    BuildContext context,
    dynamic profile,
    isDarkMode,
  ) {
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
              isDarkMode ? Colors.white : Colors.black,
              FontWeight.w700,
            ).copyWith(letterSpacing: -0.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2A1F35) : Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 16,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  profile.universityData?['name'] as String? ?? 'University',
                  style: appStyle(
                    13,
                    isDarkMode ? Colors.grey[400]! : Colors.grey[700]!,
                    FontWeight.w600,
                  ),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: appStyle(
            20,
            isDarkMode ? Colors.white : Colors.black,
            FontWeight.w700,
          ).copyWith(letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        Text(
          profile.bio ?? 'No bio yet. Tap edit to add one!',
          style: appStyle(
            14,
            hasBio
                ? (isDarkMode ? Colors.grey[300]! : Colors.grey[800]!)
                : Colors.orange[900]!,
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

  Widget _buildInterestsSection(dynamic profile, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interests', style: appStyle(20.sp, textColor, FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profile.interests.map<Widget>((interest) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDarkMode ? Colors.grey[600]! : Colors.grey[200]!,
                ),
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getInterestEmoji(interest),
                    style: appStyle(16.sp, textColor, FontWeight.w600),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    interest,
                    style: appStyle(
                      14.sp,
                      isDarkMode ? Colors.white : Colors.black,
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

  Widget _buildDetailsSection(dynamic profile, isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: appStyle(
            20,
            isDarkMode ? Colors.white : Colors.black,
            FontWeight.w700,
          ).copyWith(letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        if (profile.course != null && profile.course!.isNotEmpty)
          _buildDetailItem(
            icon: Icons.school_outlined,
            label: 'Course',
            value: profile.course!,
            isDarkMode: isDarkMode,
          ),
        if (profile.graduationYear != null)
          _buildDetailItem(
            icon: Iconsax.calendar_copy,
            label: 'Graduation Year',
            value: profile.graduationYear.toString(),
            isDarkMode: isDarkMode,
          ),
        if (profile.gender != null && profile.gender!.isNotEmpty)
          _buildDetailItem(
            icon: Iconsax.user_copy,
            label: 'Gender',
            value: profile.gender!.toUpperCase(),
            isDarkMode: isDarkMode,
          ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A1F35) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF352844) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDarkMode ? Colors.grey[600]! : Colors.grey[200]!,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: appStyle(
                    11,
                    isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                    FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: appStyle(
                    15.sp,
                    isDarkMode ? Colors.white : Colors.black,
                    FontWeight.w700,
                  ),
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
            onPressed: () => ProfileDialogs.showLogoutDialog(context, ref),
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
}
