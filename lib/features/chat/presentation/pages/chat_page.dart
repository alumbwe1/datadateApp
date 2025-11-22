import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_style.dart';
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

    // Load chat rooms
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRoomsProvider.notifier).loadChatRooms();
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
    final rooms = chatRoomsState.rooms;

    print('🔍 Chat Page - Rooms loaded: ${rooms.length}');
    print('🔍 Chat Page - Is loading: ${chatRoomsState.isLoading}');
    print('🔍 Chat Page - Error: ${chatRoomsState.error}');

    // Filter rooms based on search
    final filteredRooms = _searchController.text.isEmpty
        ? rooms
        : rooms.where((room) {
            return room.otherParticipant.displayName.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
          }).toList();

    // Separate new matches (unread > 0 and no last message yet)
    final newMatches = filteredRooms
        .where((room) => room.lastMessage == null && room.unreadCount > 0)
        .toList();
    final conversations = filteredRooms
        .where((room) => room.lastMessage != null || room.unreadCount == 0)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Messages',
            style: appStyle(
              24,
              Colors.black,
              FontWeight.w700,
            ).copyWith(letterSpacing: -0.5),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, size: 24, color: Colors.black),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 0.5, color: Colors.grey[200]),
        ),
      ),
      body: chatRoomsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            )
          : chatRoomsState.error != null
          ? _buildErrorState(chatRoomsState.error!)
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(chatRoomsProvider.notifier).loadChatRooms();
              },
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  if (newMatches.isNotEmpty) ...[
                    _buildNewMatchesHeader(newMatches.length),
                    _buildNewMatchesList(newMatches),
                    Divider(height: 1, color: Colors.grey[200]),
                  ],
                  Expanded(
                    child: conversations.isEmpty && newMatches.isEmpty
                        ? _buildEmptyState()
                        : _buildConversationsList(conversations),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _searchController,
          onTap: () {
            setState(() => _isSearching = true);
            HapticFeedback.selectionClick();
          },
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: appStyle(16, Colors.grey[600]!, FontWeight.w400),
            prefixIcon: Icon(
              IconlyLight.search,
              color: Colors.grey[600],
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.cancel, color: Colors.grey[600], size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      HapticFeedback.lightImpact();
                    },
                  )
                : null,
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildNewMatchesHeader(int count) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        'New Matches',
        style: appStyle(
          15,
          Colors.black,
          FontWeight.w600,
        ).copyWith(letterSpacing: -0.2),
      ),
    );
  }

  Widget _buildNewMatchesList(List rooms) {
    return Container(
      color: Colors.white,
      height: 110,
      padding: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        physics: const BouncingScrollPhysics(),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
              ),
            ),
            child: _buildNewMatchCard(room),
          );
        },
      ),
    );
  }

  Widget _buildNewMatchCard(room) {
    final imageUrl = room.otherParticipant.profilePhoto;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(roomId: room.id),
          ),
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 16, bottom: 8),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ClipOval(
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Container(color: Colors.grey[200]),
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
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 16,
                      color: Color(0xFFFF6B9D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              room.otherParticipant.displayName.split(' ').first,
              style: appStyle(
                13,
                Colors.black87,
                FontWeight.w600,
              ).copyWith(letterSpacing: -0.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesHeader(int count) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Text(
            'Messages',
            style: appStyle(
              17,
              Colors.black,
              FontWeight.w700,
            ).copyWith(letterSpacing: -0.4),
          ),
          const Spacer(),
          Text(
            '$count',
            style: appStyle(14, Colors.grey.shade500, FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(List rooms) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          final room = rooms[index];
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  0.3 + (index * 0.05),
                  1.0,
                  curve: Curves.easeOut,
                ),
              ),
            ),
            child: _buildMessageTile(room, index),
          );
        },
      ),
    );
  }

  Widget _buildMessageTile(room, int index) {
    final imageUrl = room.otherParticipant.profilePhoto;
    final hasUnread = room.unreadCount > 0;
    final lastMessage = room.lastMessage;
    final isOnline = room.otherParticipant.isOnline ?? false;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailPage(roomId: room.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: hasUnread ? Colors.grey.shade50 : Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hasUnread
                          ? const Color(0xFFFF6B9D)
                          : Colors.grey.shade200,
                      width: hasUnread ? 2.5 : 2,
                    ),
                    boxShadow: hasUnread
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFFF6B9D,
                              ).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: ClipOval(
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[200]),
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
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D9A3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
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
                            16,
                            Colors.black,
                            hasUnread ? FontWeight.w700 : FontWeight.w600,
                          ).copyWith(letterSpacing: -0.3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessage != null)
                        Text(
                          timeago.format(
                            DateTime.parse(lastMessage.createdAt),
                            locale: 'en_short',
                          ),
                          style: appStyle(
                            12,
                            hasUnread ? const Color(0xFFFF6B9D) : Colors.grey,
                            hasUnread ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage?.content ?? 'Start a conversation',
                          style: appStyle(
                            14,
                            hasUnread ? Colors.black87 : Colors.grey.shade600,
                            hasUnread ? FontWeight.w600 : FontWeight.w400,
                          ).copyWith(letterSpacing: -0.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB3)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${room.unreadCount}',
                            style: appStyle(11, Colors.white, FontWeight.w700),
                          ),
                        ),
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
      color: Colors.grey[300],
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: appStyle(24, Colors.grey[600]!, FontWeight.w700),
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('💬', style: TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Messages Yet',
              style: appStyle(24, Colors.black, FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start swiping to match with people\nand begin conversations',
              style: appStyle(
                15,
                Colors.grey[600]!,
                FontWeight.w500,
              ).copyWith(height: 1.5),
              textAlign: TextAlign.center,
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
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 24),
            Text('Oops!', style: appStyle(24, Colors.black, FontWeight.w800)),
            const SizedBox(height: 12),
            Text(
              error,
              style: appStyle(15, Colors.grey[600]!, FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(chatRoomsProvider.notifier).loadChatRooms();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B9D),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Try Again',
                style: appStyle(15, Colors.white, FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
