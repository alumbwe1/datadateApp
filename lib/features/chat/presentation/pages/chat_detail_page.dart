import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconly/iconly.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_style.dart';
import '../providers/chat_detail_provider.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final int roomId;

  const ChatDetailPage({super.key, required this.roomId});

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    });

    // Load more messages when scrolling to top
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ref
            .read(chatDetailProvider(widget.roomId).notifier)
            .loadMessages(isLoadMore: true);
      }
    });
  }

  void _onTextChanged() {
    final newIsTyping = _messageController.text.isNotEmpty;
    if (newIsTyping != _isTyping) {
      setState(() {
        _isTyping = newIsTyping;
      });
      // Send typing indicator
      ref
          .read(chatDetailProvider(widget.roomId).notifier)
          .sendTypingIndicator(newIsTyping);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(chatDetailProvider(widget.roomId).notifier).sendMessage(content);
    _messageController.clear();
    _scrollToBottom();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatDetailProvider(widget.roomId));
    final room = chatState.room;

    if (chatState.isLoading && room == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
          ),
        ),
      );
    }

    if (chatState.error != null && room == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Center(
          child: Text(
            chatState.error!,
            style: appStyle(15, Colors.red, FontWeight.w500),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(room),
      body: Column(
        children: [
          if (chatState.isTyping) _buildTypingIndicator(),
          Expanded(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                HapticFeedback.selectionClick();
              },
              child: chatState.messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      physics: const BouncingScrollPhysics(),
                      reverse: true,
                      itemCount:
                          chatState.messages.length +
                          (chatState.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatState.messages.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF6B9D),
                                ),
                              ),
                            ),
                          );
                        }

                        final message = chatState.messages[index];
                        final isSent =
                            message.sender == room?.participant1 ||
                            message.sender == room?.participant2;
                        final showAvatar =
                            index == 0 ||
                            chatState.messages[index - 1].sender !=
                                message.sender;

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: _buildMessageBubble(
                            message,
                            isSent,
                            showAvatar,
                            room,
                          ),
                        );
                      },
                    ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(room) {
    final otherUser = room?.otherParticipant;
    final imageUrl = otherUser?.profilePhoto;
    final isOnline = otherUser?.isOnline ?? false;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leadingWidth: 40,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () {
          Navigator.pop(context);
          HapticFeedback.lightImpact();
        },
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 2),
                ),
                child: ClipOval(
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                otherUser?.displayName[0].toUpperCase() ?? '?',
                                style: appStyle(
                                  18,
                                  Colors.grey[600]!,
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Text(
                              otherUser?.displayName[0].toUpperCase() ?? '?',
                              style: appStyle(
                                18,
                                Colors.grey[600]!,
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D9A3),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: appStyle(
                    12,
                    isOnline ? const Color(0xFF00D9A3) : Colors.grey,
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.more_vert, size: 22, color: Colors.black87),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showOptionsBottomSheet();
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'Typing',
            style: appStyle(12, Colors.grey[600]!, FontWeight.w500),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 20,
            height: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        -4 * (value > 0.5 ? 1 - value : value) * 2,
                      ),
                      child: child,
                    );
                  },
                  onEnd: () {
                    if (mounted) setState(() {});
                  },
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(message, bool isSent, bool showAvatar, room) {
    final imageUrl = room?.otherParticipant?.profilePhoto;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
        left: isSent ? 60 : 0,
        right: isSent ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment: isSent
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent && showAvatar)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: ClipOval(
                child: imageUrl != null
                    ? CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
                    : Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            room?.otherParticipant?.displayName[0]
                                    .toUpperCase() ??
                                '?',
                            style: appStyle(
                              14,
                              Colors.grey[600]!,
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
              ),
            )
          else if (!isSent)
            const SizedBox(width: 40),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isSent
                    ? const LinearGradient(
                        colors: [Color(0xFF000000), Color(0xFF2a2a2a)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSent ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isSent ? 20 : 4),
                  bottomRight: Radius.circular(isSent ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: appStyle(
                      15,
                      isSent ? Colors.white : Colors.black87,
                      FontWeight.w400,
                    ).copyWith(height: 1.4, letterSpacing: -0.2),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeago.format(
                          DateTime.parse(message.createdAt),
                          locale: 'en_short',
                        ),
                        style: appStyle(
                          11,
                          isSent
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.grey,
                          FontWeight.w500,
                        ),
                      ),
                      if (isSent) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? const Color(0xFF00D9A3)
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: appStyle(
                            15,
                            Colors.grey.shade400,
                            FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        style: appStyle(15, Colors.black87, FontWeight.w400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _isTyping
                      ? const LinearGradient(
                          colors: [Color(0xFF000000), Color(0xFF2a2a2a)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _isTyping ? null : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  boxShadow: _isTyping
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  IconlyBold.send,
                  color: _isTyping ? Colors.white : Colors.grey.shade400,
                  size: 22,
                ),
              ),
            ),
          ],
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👋', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start the Conversation',
              style: appStyle(22, Colors.black, FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Say hi and break the ice!',
              style: appStyle(15, Colors.grey[600]!, FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: Text(
                  'Block User',
                  style: appStyle(15, Colors.red, FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: Colors.orange),
                title: Text(
                  'Report',
                  style: appStyle(15, Colors.orange, FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
