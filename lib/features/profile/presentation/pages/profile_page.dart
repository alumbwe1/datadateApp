import 'package:cached_network_image/cached_network_image.dart';
import 'package:datadate/core/constants/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No user data')));
    }

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 32),
              _buildInfoSection('About', user),
              const SizedBox(height: 24),
              _buildInterestsSection(),
              const SizedBox(height: 24),
              _buildPhotosSection(user),
              const SizedBox(height: 32),
              _buildActionButtons(context, ref),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateProfileCompletion(dynamic user) {
    int score = 0;
    if (user.photos.isNotEmpty) score += 30;
    if (user.bio != null && user.bio.isNotEmpty) score += 20;
    if (user.name.isNotEmpty) score += 20;
    if (user.age > 0) score += 10;
    if (user.university != null) score += 10;
    if (user.relationshipGoal != null) score += 10;
    return score;
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    final completionPercentage = _calculateProfileCompletion(user);

    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress indicator
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: completionPercentage / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completionPercentage >= 80
                        ? Colors.blue
                        : completionPercentage >= 50
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ),
              // Profile photo
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: user.photos.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: user.photos.first,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
              ),
              // Completion percentage badge
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: completionPercentage >= 80
                          ? Colors.blue
                          : completionPercentage >= 50
                          ? Colors.orange
                          : Colors.red,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
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
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$completionPercentage%',
                          style: appStyle(
                            13,
                            Colors.white,
                            FontWeight.w800,
                          ).copyWith(letterSpacing: -0.2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${user.name}, ${user.age}',
            style: appStyle(
              28,
              Colors.black,
              FontWeight.w900,
            ).copyWith(letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                user.university ?? 'University',
                style: appStyle(15, Colors.grey[700]!, FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.heart, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  'Here for ${user.relationshipGoal}',
                  style: appStyle(14, Colors.grey[700]!, FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: appStyle(
            20,
            Colors.black,
            FontWeight.w800,
          ).copyWith(letterSpacing: -0.3),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            user.bio ?? 'No bio yet. Tap to add one!',
            style: appStyle(
              15,
              Colors.grey[800]!,
              FontWeight.w400,
            ).copyWith(height: 1.5, letterSpacing: -0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    final interests = [
      '📷 Photography',
      '🎵 Music',
      '✈️ Travel',
      '💪 Fitness',
      '🍳 Cooking',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Interests',
          style: appStyle(
            20,
            Colors.black,
            FontWeight.w800,
          ).copyWith(letterSpacing: -0.3),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: interests.map((interest) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                interest,
                style: appStyle(14, Colors.black, FontWeight.w600),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotosSection(dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photos',
              style: appStyle(
                20,
                Colors.black,
                FontWeight.w800,
              ).copyWith(letterSpacing: -0.3),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 20, color: Colors.black),
              label: Text(
                'Add',
                style: appStyle(15, Colors.black, FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: user.photos.length + 1,
          itemBuilder: (context, index) {
            if (index == user.photos.length) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: Icon(Icons.add, size: 40, color: Colors.grey[400]),
              );
            }
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(user.photos[index]),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Edit Profile',
              style: appStyle(16, Colors.white, FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showLogoutDialog(context, ref),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.red, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Logout',
              style: appStyle(16, Colors.red, FontWeight.w700),
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
          color: color.withOpacity(0.1),
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
