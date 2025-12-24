import 'package:datadate/core/utils/custom_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_style.dart';
import '../../../../core/widgets/connectivity_app_bar.dart';
import '../../../interactions/presentation/providers/matches_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_empty_state.dart';
import '../widgets/chat_error_state.dart';
import '../widgets/chat_page_shimmer.dart';
import '../widgets/chat_search_bar.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/matches_section.dart';

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

  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load only once when page becomes visible
    if (!_hasLoaded) {
      _hasLoaded = true;
      Future.microtask(() {
        ref.read(chatRoomsProvider.notifier).loadChatRooms();
        ref.read(matchesProvider.notifier).loadMatches();
      });
    }
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      appBar: ConnectivityAppBar(
        title: 'HeartLink',
        showConnectivityIndicator: true,
        onRefresh: () async {
          await Future.wait([
            ref.read(chatRoomsProvider.notifier).loadChatRooms(),
            ref.read(matchesProvider.notifier).loadMatches(),
          ]);
        },
      ),
      body: chatRoomsState.isLoading && matchesState.isLoading
          ? const ChatPageShimmer()
          : chatRoomsState.error != null
          ? ChatErrorState(
              error: chatRoomsState.error!,
              onRetry: () {
                ref.read(chatRoomsProvider.notifier).loadChatRooms();
              },
            )
          : RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await Future.wait([
                  ref.read(chatRoomsProvider.notifier).loadChatRooms(),
                  ref.read(matchesProvider.notifier).loadMatches(),
                ]);
              },
              color: AppColors.secondaryLight,
              backgroundColor: isDarkMode
                  ? const Color(0xFF2A1F35)
                  : Colors.white,
              strokeWidth: 2.5,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ChatSearchBar(
                      controller: _searchController,
                      isSearching: _isSearching,
                      onTap: () => setState(() => _isSearching = true),
                      onChanged: (value) => setState(() {}),
                      onClear: () => setState(() {}),
                    ),
                  ),
                  SliverToBoxAdapter(child: MatchesSection(matches: matches)),
                  if (conversations.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: _buildMessagesTitle(conversations.length),
                    ),
                  ],
                  if (conversations.isEmpty && matches.isEmpty)
                    const SliverFillRemaining(child: ChatEmptyState())
                  else
                    _buildConversationsList(conversations),
                ],
              ),
            ),
    );
  }

  Widget _buildMessagesTitle(int count) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? const Color(0xFF1A1625) : Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Text(
            'Messages',
            style: appStyle(
              12.sp,
              isDarkMode ? Colors.grey[400]! : Colors.grey.shade500,
              FontWeight.w700,
            ).copyWith(letterSpacing: -0.3, height: 1.2),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: appStyle(
                11.sp,
                isDarkMode ? Colors.grey[300]! : Colors.grey.shade600,
                FontWeight.w700,
              ).copyWith(letterSpacing: -0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(List rooms) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (rooms.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No conversations yet',
                style: appStyle(
                  16,
                  isDarkMode ? Colors.grey[400]! : Colors.grey[600]!,
                  FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final room = rooms[index];
        return ConversationTile(room: room, index: index);
      }, childCount: rooms.length),
    );
  }
}
