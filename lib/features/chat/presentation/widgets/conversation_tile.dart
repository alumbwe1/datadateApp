import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../pages/chat_detail_page.dart';

class ConversationTile extends ConsumerWidget {
  final dynamic room;
  final int index;

  const ConversationTile({super.key, required this.room, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = room.otherParticipant.profilePhoto;
    final hasUnread = room.unreadCount > 0;
    final lastMessage = room.lastMessage;
    final isOnline = room.otherParticipant.isOnline ?? false;

    String messagePreview = 'Start a conversation';
    if (lastMessage != null) {
      final currentUserId = ref.watch(authProvider).user?.id;
      final isMyMessage =
          currentUserId != null &&
          lastMessage.sender.toString() == currentUserId;

      if (isMyMessage) {
        messagePreview = 'You: ${lastMessage.content}';
      } else {
        messagePreview = lastMessage.content;
      }
    }

    return InkWell(
      onTap: () async {
        HapticFeedback.mediumImpact();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(roomId: room.id),
          ),
        );
        ref.read(chatRoomsProvider.notifier).loadChatRooms();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: hasUnread
              ? AppColors.secondaryLight.withOpacity(0.02)
              : Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            _buildAvatar(imageUrl, isOnline, hasUnread),
            const SizedBox(width: 14),
            Expanded(
              child: _buildContent(
                context,
                hasUnread,
                lastMessage,
                messagePreview,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, bool isOnline, bool hasUnread) {
    return Stack(
      children: [
        Hero(
          tag: 'chat_avatar_${room.id}',
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: hasUnread
                  ? [
                      BoxShadow(
                        color: AppColors.secondaryLight.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[200]!,
                        highlightColor: Colors.grey[50]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildAvatarPlaceholder(
                            room.otherParticipant.displayName,
                          ),
                    )
                  : _buildAvatarPlaceholder(room.otherParticipant.displayName),
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentLight.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool hasUnread,
    dynamic lastMessage,
    String messagePreview,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                room.otherParticipant.displayName,
                style: appStyle(
                  16.5,
                  Colors.black,
                  hasUnread ? FontWeight.w700 : FontWeight.w600,
                ).copyWith(letterSpacing: -0.4, height: 1.2),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (lastMessage != null) _buildTimestamp(hasUnread, lastMessage),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Expanded(
              child: Text(
                messagePreview,
                style: appStyle(
                  14,
                  hasUnread ? Colors.black87 : Colors.grey.shade500,
                  hasUnread ? FontWeight.w500 : FontWeight.w400,
                ).copyWith(letterSpacing: -0.3, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasUnread) ...[const SizedBox(width: 10), _buildUnreadBadge()],
          ],
        ),
      ],
    );
  }

  Widget _buildTimestamp(bool hasUnread, dynamic lastMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasUnread
            ? AppColors.secondaryLight.withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        timeago.format(
          DateTime.parse(lastMessage.createdAt),
          locale: 'en_short',
        ),
        style: appStyle(
          11,
          hasUnread ? AppColors.secondaryLight : Colors.grey[600]!,
          hasUnread ? FontWeight.w700 : FontWeight.w600,
        ).copyWith(letterSpacing: -0.2),
      ),
    );
  }

  Widget _buildUnreadBadge() {
    return Container(
      constraints: const BoxConstraints(minWidth: 24),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondaryLight,
            AppColors.secondaryLight.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryLight.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        room.unreadCount > 99 ? '99+' : '${room.unreadCount}',
        style: appStyle(
          11.5,
          Colors.white,
          FontWeight.w700,
        ).copyWith(letterSpacing: -0.3),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[200]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: appStyle(22, Colors.grey[600]!, FontWeight.w700),
        ),
      ),
    );
  }
}
