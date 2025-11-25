import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/app_style.dart';
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
    // Load profile data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          'Profile',
          style: appStyle(
            28,
            Colors.black,
            FontWeight.bold,
          ).copyWith(letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Colors.black,
              size: 28,
            ),
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
              // Circular progress indicator with gradient
              SizedBox(
                width: 160,
                height: 160,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: completionPercentage / 100),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 7,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              // Profile photo with enhanced shadow
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: progressColor.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
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
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.grey[300]!, Colors.grey[200]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              size: 70,
                              color: Colors.grey[400],
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.grey[300]!, Colors.grey[200]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
              ),
              // Completion percentage badge with animation
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                progressColor,
                                progressColor.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: progressColor.withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                completionPercentage >= 80
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$completionPercentage%',
                                style: appStyle(
                                  14,
                                  Colors.white,
                                  FontWeight.w900,
                                ).copyWith(letterSpacing: -0.3),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            profile.age != null
                ? '${profile.realName ?? profile.displayName}, ${profile.age}'
                : profile.realName ?? profile.displayName,
            style: appStyle(
              30,
              Colors.black,
              FontWeight.w900,
            ).copyWith(letterSpacing: -0.8, height: 1.1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_outlined, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    profile.universityData?['name'] as String? ?? 'University',
                    style: appStyle(
                      14,
                      Colors.grey[700]!,
                      FontWeight.w600,
                    ).copyWith(letterSpacing: -0.2),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink[50]!, Colors.red[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.pink[100]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.heart, size: 16, color: Colors.red[400]),
                const SizedBox(width: 8),
                Text(
                  'Here for ${profile.intent ?? 'dating'}',
                  style: appStyle(
                    14,
                    Colors.red[700]!,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: -0.2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    // TODO: Replace with real data from API
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[50]!, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Views', '0', Icons.visibility_outlined, Colors.blue),
          Container(
            width: 1.5,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[200]!,
                  Colors.grey[300]!,
                  Colors.grey[200]!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          _buildStatItem('Likes', '0', Icons.favorite_outline, Colors.red),
          Container(
            width: 1.5,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[200]!,
                  Colors.grey[300]!,
                  Colors.grey[200]!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          _buildStatItem('Matches', '0', Icons.people_outline, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: appStyle(
            20,
            Colors.black,
            FontWeight.w900,
          ).copyWith(letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: appStyle(
            11,
            Colors.grey[600]!,
            FontWeight.w600,
          ).copyWith(letterSpacing: -0.2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, dynamic profile) {
    final hasBio = profile.bio != null && profile.bio!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: appStyle(
                22,
                Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasBio
                  ? [Colors.grey[50]!, Colors.grey[100]!]
                  : [Colors.orange[50]!, Colors.orange[100]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasBio ? Colors.grey[200]! : Colors.orange[200]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!hasBio)
                Icon(Icons.edit_outlined, size: 20, color: Colors.orange[700]),
              if (!hasBio) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  profile.bio ?? 'No bio yet. Tap edit to add one!',
                  style: appStyle(
                    15,
                    hasBio ? Colors.grey[800]! : Colors.orange[900]!,
                    hasBio ? FontWeight.w500 : FontWeight.w600,
                  ).copyWith(height: 1.6, letterSpacing: -0.2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection(dynamic profile) {
    final colors = [
      [Colors.purple[50]!, Colors.purple[100]!, Colors.purple[700]!],
      [Colors.blue[50]!, Colors.blue[100]!, Colors.blue[700]!],
      [Colors.green[50]!, Colors.green[100]!, Colors.green[700]!],
      [Colors.orange[50]!, Colors.orange[100]!, Colors.orange[700]!],
      [Colors.pink[50]!, Colors.pink[100]!, Colors.pink[700]!],
      [Colors.teal[50]!, Colors.teal[100]!, Colors.teal[700]!],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[50]!, Colors.purple[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.favorite_outline,
                size: 20,
                color: Colors.purple[700],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Interests',
              style: appStyle(
                22,
                Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: profile.interests.asMap().entries.map<Widget>((entry) {
            final index = entry.key;
            final interest = entry.value;
            final colorSet = colors[index % colors.length];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorSet[0], colorSet[1]],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorSet[1], width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: colorSet[2].withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                interest,
                style: appStyle(
                  14,
                  colorSet[2],
                  FontWeight.w700,
                ).copyWith(letterSpacing: -0.2),
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.info, size: 20, color: Colors.green[700]),
            ),
            const SizedBox(width: 12),
            Text(
              'Details',
              style: appStyle(
                22,
                Colors.black,
                FontWeight.w900,
              ).copyWith(letterSpacing: -0.5),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (profile.course != null && profile.course!.isNotEmpty)
          _buildDetailItem(
            icon: Icons.school,
            label: 'Course',
            value: profile.course!,
            color: Colors.blue,
          ),
        if (profile.graduationYear != null)
          _buildDetailItem(
            icon: Icons.calendar_today,
            label: 'Graduation Year',
            value: profile.graduationYear.toString(),
            color: Colors.orange,
          ),
        if (profile.gender != null && profile.gender!.isNotEmpty)
          _buildDetailItem(
            icon: Icons.person_outline,
            label: 'Gender',
            value: profile.gender!.toUpperCase(),
            color: Colors.purple,
          ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.08),
            color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: appStyle(
                    12,
                    Colors.grey[600]!,
                    FontWeight.w600,
                  ).copyWith(letterSpacing: -0.1),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: appStyle(
                    16,
                    Colors.black,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: -0.3),
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
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.black, Color(0xFF2C2C2C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 22,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Edit Profile',
                      style: appStyle(
                        17,
                        Colors.white,
                        FontWeight.w800,
                      ).copyWith(letterSpacing: -0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showLogoutDialog(context, ref),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(color: Colors.red[400]!, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.red[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, size: 22, color: Colors.red[700]),
                const SizedBox(width: 10),
                Text(
                  'Logout',
                  style: appStyle(
                    17,
                    Colors.red[700]!,
                    FontWeight.w800,
                  ).copyWith(letterSpacing: -0.3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              _buildBottomSheetOption(
                'Account Settings',
                Icons.person_outline,
                Colors.blue,
                () => Navigator.pop(context),
              ),
              _buildBottomSheetOption(
                'Privacy',
                Icons.lock_outline,
                Colors.green,
                () => Navigator.pop(context),
              ),
              _buildBottomSheetOption(
                'Notifications',
                Icons.notifications_outlined,
                Colors.orange,
                () => Navigator.pop(context),
              ),
              _buildBottomSheetOption(
                'Help & Support',
                Icons.help_outline,
                Colors.purple,
                () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
