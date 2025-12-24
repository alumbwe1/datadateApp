import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/connectivity_indicator.dart';

class PremiumChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final dynamic room;
  final VoidCallback onBackPressed;
  final VoidCallback onOptionsPressed;
  final VoidCallback? onProfileTap;

  const PremiumChatAppBar({
    super.key,
    required this.room,
    required this.onBackPressed,
    required this.onOptionsPressed,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUser = room?.otherParticipant;
    final imageUrl = otherUser?.profilePhoto;
    final isOnline = otherUser?.isOnline ?? false;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Icon(Icons.arrow_back, size: 20.sp, color: Colors.black),
          onPressed: () {
            onBackPressed();
            HapticFeedback.lightImpact();
          },
        ),
      ),
      title: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onProfileTap?.call();
        },
        child: Row(
          children: [
            Hero(
              tag: 'avatar_${room?.id}',
              child: Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.grey.shade200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.grey.shade200, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[100]),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: Text(
                                    otherUser?.displayName[0].toUpperCase() ??
                                        '?',
                                    style: appStyle(
                                      16,
                                      Colors.grey[700]!,
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: Text(
                                  otherUser?.displayName[0].toUpperCase() ??
                                      '?',
                                  style: appStyle(
                                    16,
                                    Colors.grey[700]!,
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    otherUser?.displayName ?? 'Chat',
                    style: appStyle(
                      17,
                      Colors.black,
                      FontWeight.w700,
                    ).copyWith(letterSpacing: -0.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isOnline)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Text(
                            'Active now',
                            style: appStyle(12, Colors.green, FontWeight.w600),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        const ConnectivityIndicator(
          showInAppBar: true,
          showText: false,
          compact: true,
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.more_horiz, size: 20, color: Colors.black),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            onOptionsPressed();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
