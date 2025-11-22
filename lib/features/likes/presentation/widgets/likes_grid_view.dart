import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../interactions/data/models/like_model.dart';
import '../providers/likes_provider.dart';
import 'likes_empty_state.dart';
import 'received_like_card.dart';
import 'sent_like_card.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'View ${userInfo.displayName}\'s profile',
          style: appStyle(14, Colors.white, FontWeight.w600),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
