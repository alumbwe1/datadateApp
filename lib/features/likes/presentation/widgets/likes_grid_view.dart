import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../encounters/domain/entities/profile.dart';
import '../../../encounters/presentation/pages/profile_details_page.dart';
import '../../../interactions/data/models/like_model.dart';
import '../providers/likes_provider.dart';
import 'likes_empty_state.dart';
import 'received_like_card.dart';
import 'sent_like_card.dart';

class LikesGridView extends ConsumerWidget {
  final List<LikeModel> likes;
  final bool isReceived;

  const LikesGridView({
    super.key,
    required this.likes,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (likes.isEmpty) {
      return LikesEmptyState(isReceived: isReceived);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(likesProvider.notifier).loadAllLikes();
      },
      color: AppColors.secondaryLight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8.h),
              child: GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: likes.length,
                itemBuilder: (context, index) {
                  final like = likes[index];
                  final userInfo = isReceived ? like.liker : like.liked;

                  if (userInfo == null) {
                    return const SizedBox.shrink();
                  }

                  final profile = userInfo.profile;
                  final imageUrl = profile?.imageUrls.isNotEmpty == true
                      ? profile!.imageUrls.first
                      : null;

                  if (isReceived) {
                    return ReceivedLikeCard(
                      userInfo: userInfo,
                      profile: profile,
                      imageUrl: imageUrl,
                      createdAt: like.createdAt ?? '',
                      index: index,
                      onTap: () => _showProfileSnackbar(context, userInfo),
                    );
                  } else {
                    return SentLikeCard(
                      userInfo: userInfo,
                      profile: profile,
                      imageUrl: imageUrl,
                      createdAt: like.createdAt ?? '',
                      onTap: () => _showProfileSnackbar(context, userInfo),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileSnackbar(BuildContext context, UserInfo userInfo) {
    // Convert UserInfo to Profile entity
    final profile = _convertToProfile(userInfo);

    if (profile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileDetailsPage(profile: profile),
        ),
      );
    }
  }

  Profile? _convertToProfile(UserInfo userInfo) {
    final profileData = userInfo.profile;
    if (profileData == null) return null;

    return Profile(
      id: userInfo.id,
      displayName: userInfo.displayName,
      username: userInfo.username,
      email: '', // Not available in likes response
      universityName: profileData.university?.name ?? 'Unknown University',
      universityLogo: '', // Not available in likes response
      age: profileData.age ?? 0,
      gender: profileData.gender ?? '',
      intent: 'dating', // Default value
      bio: profileData.bio,
      photos: profileData.imageUrls.isNotEmpty
          ? profileData.imageUrls
          : ['https://via.placeholder.com/400'],
      interests: profileData.interests,
      lastActive: profileData.lastActive != null
          ? DateTime.tryParse(profileData.lastActive!)
          : null,
    );
  }
}
