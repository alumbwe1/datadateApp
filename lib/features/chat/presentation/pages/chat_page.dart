import 'package:datadate/core/utils/custom_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../interactions/presentation/providers/matches_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_detail_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRoomsProvider.notifier).loadChatRooms();
      ref.read(matchesProvider.notifier).loadMatches();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      ref.read(chatRoomsProvider.notifier).loadChatRooms();
      ref.read(matchesProvider.notifier).loadMatches();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomsState = ref.watch(chatRoomsProvider);
    final matchesState = ref.watch(matchesProvider);
    final rooms = chatRoomsState.rooms;
    final matches = matchesState.matches;

    CustomLogs.info('🔍 Chat Page - Rooms loaded: ${rooms.length}');
    CustomLogs.info('🔍 Chat Page - Matches loaded: ${matches.length}');
    CustomLogs.info('🔍 Chat Page - Is loading: ${chatRoomsState.isLoading}');
    CustomLogs.info('🔍 Chat Page - Error: ${chatRoomsState.error}');

    final filteredRooms = _searchController.text.isEmpty
        ? rooms
        : rooms.where((room) {
            return room.otherParticipant.displayName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
          }).toList();

    final conversations = filteredRooms;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildModernAppBar(rooms.length, matches.length),
      body: chatRoomsState.isLoading && matchesState.isLoading
          ? _buildShimmerLoading()
          : chatRoomsState.error != null
          ? _buildErrorState(chatRoomsState.error!)
          : RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await Future.wait([
                  ref.read(chatRoomsProvider.notifier).loadChatRooms(),
                  ref.read(matchesProvider.notifier).loadMatches(),
                ]);
              },
              color: AppColors.secondaryLight,
              backgroundColor: Colors.white,
              strokeWidth: 2.5,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  if (matches.isNotEmpty) ...[
                    SliverToBoxAdapter(child: _buildMatchesSection(matches)),
                  ],
                  if (conversations.isEmpty && matches.isEmpty)
                    SliverFillRemaining(child: _buildEmptyState())
                  else
                    _buildConversationsList(conversations),
                ],
              ),
            ),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar shimmer
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // New matches shimmer
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          height: 110,
          padding: const EdgeInsets.only(bottom: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 12,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Conversations shimmer
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 16,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 14,
                                width: MediaQuery.of(context).size.width * 0.6,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildModernAppBar(int roomsCount, int matchesCount) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.heartGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: Text(
                  'HeartLink',
                  style: appStyle(
                    25,
                    Colors.white,
                    FontWeight.w800,
                  ).copyWith(letterSpacing: -0.3),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: TextField(
          controller: _searchController,
          onTap: () {
            setState(() => _isSearching = true);
            HapticFeedback.selectionClick();
          },
          onChanged: (value) => setState(() {}),
          style: appStyle(15, Colors.black87, FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: appStyle(
              15,
              Colors.grey[600]!,
              FontWeight.w400,
            ).copyWith(letterSpacing: -0.3),
            prefixIcon: Icon(
              IconlyLight.search,
              color: _isSearching ? AppColors.secondaryLight : Colors.grey[600],
              size: 22,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      HapticFeedback.lightImpact();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchesSection(List matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Matches',
                      style: appStyle(
                        12.sp,
                        Colors.grey.shade500,
                        FontWeight.w700,
                      ).copyWith(letterSpacing: -0.3, height: 1.2),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${matches.length}',
                  style: appStyle(
                    12.sp,
                    AppColors.secondaryLight,
                    FontWeight.w700,
                  ).copyWith(letterSpacing: -0.3),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return _buildMatchCard(match, index);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMatchCard(match, int index) {
    final otherUser = match.otherUser;
    final profile = otherUser?.profile;
    final imageUrls = profile?.imageUrls ?? [];
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;
    final displayName = otherUser?.displayName ?? 'Unknown';
    final firstName = displayName.split(' ').first;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(roomId: match.id),
          ),
        );
      },
      child: Container(
        width: 105,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Hero(
                  tag: 'match_${match.id}',
                  child: Container(
                    width: 109,
                    height: 109,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),

                      border: Border.all(
                        color: AppColors.secondaryLight.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: Container(
                      width: 105,
                      height: 105,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 3),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondaryLight.withOpacity(0.15),
                            AppColors.secondaryLight.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                      baseColor: Colors.grey[200]!,
                                      highlightColor: Colors.grey[50]!,
                                      child: Container(color: Colors.white),
                                    ),
                                errorWidget: (context, url, error) =>
                                    _buildAvatarPlaceholder(displayName),
                              )
                            : _buildAvatarPlaceholder(displayName),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryLight,
                          AppColors.primaryLight.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.8.w),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryLight.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Iconsax.heart,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              firstName,
              style: appStyle(
                14.sp,
                Colors.black87,
                FontWeight.w700,
              ).copyWith(letterSpacing: -0.3, height: 1.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList(List rooms) {
    if (rooms.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No conversations yet',
                style: appStyle(16, Colors.grey[600]!, FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(top: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final room = rooms[index];
          return _buildMessageTile(room, index);
        }, childCount: rooms.length),
      ),
    );
  }

  Widget _buildMessageTile(room, int index) {
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'chat_avatar_${room.id}',
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(shape: BoxShape.circle),
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
                          : _buildAvatarPlaceholder(
                              room.otherParticipant.displayName,
                            ),
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
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
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
                      if (lastMessage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
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
                              hasUnread
                                  ? AppColors.secondaryLight
                                  : Colors.grey[600]!,
                              hasUnread ? FontWeight.w700 : FontWeight.w600,
                            ).copyWith(letterSpacing: -0.2),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          messagePreview,
                          style: appStyle(
                            14,
                            hasUnread ? Colors.black87 : Colors.grey.shade500,
                            hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ).copyWith(letterSpacing: -0.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 10),
                        Container(
                          constraints: const BoxConstraints(minWidth: 24),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
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
                                color: AppColors.secondaryLight.withOpacity(
                                  0.35,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            room.unreadCount > 99
                                ? '99+'
                                : '${room.unreadCount}',
                            style: appStyle(
                              11.5,
                              Colors.white,
                              FontWeight.w700,
                            ).copyWith(letterSpacing: -0.3),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondaryLight.withOpacity(0.1),
                    AppColors.secondaryLight.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryLight.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text('💬', style: TextStyle(fontSize: 64)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Messages Yet',
              style: appStyle(
                26,
                Colors.black,
                FontWeight.w800,
              ).copyWith(letterSpacing: -0.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start swiping to match with people\nand begin conversations',
              style: appStyle(
                15,
                Colors.grey[600]!,
                FontWeight.w500,
              ).copyWith(height: 1.6, letterSpacing: -0.1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondaryLight,
                    AppColors.secondaryLight.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryLight.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Start Swiping',
                    style: appStyle(
                      15,
                      Colors.white,
                      FontWeight.w700,
                    ).copyWith(letterSpacing: -0.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 50,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Oops!',
              style: appStyle(
                26,
                Colors.black,
                FontWeight.w800,
              ).copyWith(letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: appStyle(
                15,
                Colors.grey[600]!,
                FontWeight.w500,
              ).copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                ref.read(chatRoomsProvider.notifier).loadChatRooms();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.secondaryLight,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: AppColors.secondaryLight, width: 2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Try Again',
                    style: appStyle(
                      15,
                      AppColors.secondaryLight,
                      FontWeight.w700,
                    ).copyWith(letterSpacing: -0.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
